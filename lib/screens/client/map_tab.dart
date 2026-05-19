import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/auth_prompt_dialog.dart';
import '../../constants.dart';

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

// Vehicle mode model
enum VehicleMode { foot, moto, car }

extension VehicleModeExtension on VehicleMode {
  /// Mode de transport pour Google Maps URL
  String get googleMapsMode {
    switch (this) {
      case VehicleMode.foot: return 'walking';
      case VehicleMode.moto: return 'driving';
      case VehicleMode.car:  return 'driving';
    }
  }

  String get label {
    switch (this) {
      case VehicleMode.foot: return 'À pied';
      case VehicleMode.moto: return 'Moto';
      case VehicleMode.car:  return 'Voiture';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleMode.foot: return Icons.directions_walk_rounded;
      case VehicleMode.moto: return Icons.two_wheeler_rounded;
      case VehicleMode.car:  return Icons.directions_car_rounded;
    }
  }

  Color get color {
    switch (this) {
      case VehicleMode.foot: return const Color(0xFF4CAF50);
      case VehicleMode.moto: return const Color(0xFFFF9800);
      case VehicleMode.car:  return const Color(0xFF2196F3);
    }
  }
}

class _MapTabState extends State<MapTab> {
  final AuthService _authService = AuthService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _points = [];
  List<Map<String, dynamic>> _allPoints = []; // cache complet non filtré
  bool _isLoading = true;
  String? _activeFilter; // clé interne ex: 'plastique'
  String _searchQuery = '';
  LatLng? _currentLocation;
  // Vehicle selection
  VehicleMode _selectedVehicle = VehicleMode.car;

  // ── Dictionnaire bilingue FR / AR ─────────────────────────────────────────
  static const List<Map<String, String>> _typeMap = [
    {'key': 'tous',         'fr': 'Tous',         'ar': 'الكل'},
    {'key': 'plastique',    'fr': 'Plastique',    'ar': 'بلاستيك'},
    {'key': 'verre',        'fr': 'Verre',        'ar': 'زجاج'},
    {'key': 'papier',       'fr': 'Papier',       'ar': 'ورق'},
    {'key': 'carton',       'fr': 'Carton',       'ar': 'كرتون'},
    {'key': 'metal',        'fr': 'Métal',        'ar': 'معدن'},
    {'key': 'electronique', 'fr': 'Électronique', 'ar': 'إلكترونيات'},
    {'key': 'batteries',    'fr': 'Batteries',    'ar': 'بطاريات'},
    {'key': 'compost',      'fr': 'Compost',      'ar': 'سماد'},
    {'key': 'vetements',    'fr': 'Vêtements',    'ar': 'ملابس'},
    {'key': 'general',      'fr': 'Général',      'ar': 'عام'},
  ];

  /// Normalize pour comparaison insensible à la casse et aux accents
  String _norm(String s) => s.toLowerCase()
    .replaceAll(RegExp(r'[éèêë]'), 'e')
    .replaceAll(RegExp(r'[àâä]'), 'a')
    .replaceAll(RegExp(r'[îï]'), 'i')
    .replaceAll(RegExp(r'[ôö]'), 'o')
    .replaceAll(RegExp(r'[ùûü]'), 'u')
    .trim();

  /// Retourne les équivalents AR et FR pour une clé de type donnée
  List<String> _bilingualTerms(String key) {
    final e = _typeMap.firstWhere((m) => m['key'] == key, orElse: () => {});
    if (e.isEmpty) return [];
    return [_norm(e['fr']!), e['ar']!];
  }

  // ── Dictionnaire bilingue des VILLES FR ↔ AR ──────────────────────────────
  /// Chaque entrée : liste de tous les termes équivalents (FR + AR + variantes)
  static const List<List<String>> _cityTranslations = [
    ['nabeul', 'نابل', 'hammamet', 'حمامت', 'kelibia', 'قليبية', 'beni khiar', 'بني خيار', 'la jarre'],
    ['tunis', 'تونس', 'bardo', 'باردو', 'carthage', 'قرطاج'],
    ['sousse', 'سوسة', 'hammam sousse', 'حمام سوسة', 'msaken', 'مساكن'],
    ['sfax', 'صفاقس'],
    ['bizerte', 'بنزرت', 'menzel bourguiba', 'منزل بورقيبة'],
    ['ariana', 'أريانة', 'raoued', 'راوض', 'ennasr', 'النصر'],
    ['ben arous', 'بن عروس', 'rades', 'رادس', 'megrine', 'مقرين', 'ezzahra', 'الزهراء'],
    ['manouba', 'منوبة', 'oued ellil', 'وادي الليل', 'douar hicher', 'دوار هيشر'],
    ['monastir', 'المنستير', 'skanes', 'سكانس'],
    ['mahdia', 'المهدية'],
    ['kairouan', 'القيروان'],
    ['kasserine', 'القصرين'],
    ['gabes', 'قابس', 'gabès'],
    ['gafsa', 'قفصة'],
    ['medenine', 'مدنين', 'médenine', 'djerba', 'جربة', 'houmt souk', 'حومة السوق'],
    ['tozeur', 'توزر'],
    ['tataouine', 'تطاوين'],
    ['zaghouan', 'زغوان'],
    ['siliana', 'سليانة'],
    ['jendouba', 'جندوبة'],
    ['kef', 'الكاف', 'le kef'],
    ['sidi bouzid', 'سيدي بوزيد'],
    ['beja', 'باجة', 'béja'],
  ];

  /// Étend une requête de recherche à tous ses équivalents bilingues
  /// Ex: "نابل" → ['نابل', 'nabeul', 'hammamet', ...]
  List<String> _expandQuery(String query) {
    final q = query.trim();
    if (q.isEmpty) return [];
    final normalized = _norm(q);
    for (final group in _cityTranslations) {
      final normGroup = group.map(_norm).toList();
      // Si la requête correspond à l'un des termes du groupe (partiel OK)
      if (normGroup.any((t) => t.contains(normalized) || normalized.contains(t)) ||
          group.any((t) => t.contains(q) || q.contains(t))) {
        return group; // Retourne tout le groupe (FR + AR + variantes)
      }
    }
    // Pas trouvé dans les villes → retourner uniquement la requête originale
    return [q];
  }


  // Cache keys
  static const _kCachePoints   = 'map_points_cache_v2';
  static const _kCacheVersion  = 'map_points_version_v2';

  // Indique si le cache a été affiché mais qu'un refresh silencieux est en cours
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadFromCache();           // Affichage instantané depuis SharedPreferences
    _checkAndRefreshCache();    // Vérification silencieuse de la version en arrière-plan
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Cache : chargement instantané ──────────────────────────────────────────
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCachePoints);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = json.decode(raw);
        if (decoded.isNotEmpty && mounted) {
          _allPoints = decoded.cast<Map<String, dynamic>>();
          _applyFilters();
          setState(() => _isLoading = false);
          return; // Cache valide et non-vide → OK
        }
      }
      // Cache vide ou absent → fetch réseau obligatoire
      await _fetchAndCachePoints();
    } catch (_) {
      await _fetchAndCachePoints();
    }
  }

  // ── Cache : vérification version en arrière-plan ─────────────────────────────
  Future<void> _checkAndRefreshCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedVersion = prefs.getDouble(_kCacheVersion) ?? 0.0;

      // Appel ultra-léger : retourne juste un timestamp
      final uri = Uri.parse('${ApiConstants.baseUrl}/collection-points/version');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) return;

      final serverVersion = (json.decode(resp.body)['version'] as num).toDouble();

      if (serverVersion > cachedVersion) {
        // Le serveur a une version plus récente → on rafraîchit
        if (mounted) setState(() => _isRefreshing = true);
        await _fetchAndCachePoints(newVersion: serverVersion);
        if (mounted) setState(() => _isRefreshing = false);
      }
      // Sinon : le cache est à jour, on ne fait rien
    } catch (_) {
      // Pas de réseau ? On garde le cache tel quel
    }
  }

  Future<void> _fetchAndCachePoints({double? newVersion}) async {
    if (_allPoints.isEmpty && mounted) setState(() => _isLoading = true);
    try {
      final points = await _authService.fetchCollectionPoints();
      if (!mounted) return;
      // Ne jamais cacher un résultat vide (erreur réseau, tunnel inactif, etc.)
      if (points.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kCachePoints, json.encode(points));
        if (newVersion != null) await prefs.setDouble(_kCacheVersion, newVersion);
        _allPoints = points;
        _applyFilters();
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Filtre client-side bilingue FR + AR depuis le cache complet
  /// La recherche est étendue à tous les équivalents bilingues via _expandQuery
  void _applyFilters() {
    final rawQuery = _searchQuery.trim();
    final key = _activeFilter; // null = tous
    final terms = key != null && key != 'tous' ? _bilingualTerms(key) : <String>[];

    // Étend la requête : 'نابل' → ['nabeul', 'hammamet', 'نابل', 'حمامت', ...]
    final expandedTerms = rawQuery.isEmpty ? <String>[] : _expandQuery(rawQuery);

    final filtered = _allPoints.where((p) {
      // ── Recherche textuelle bilingue ──────────────────────────────
      final name    = (p['name']    ?? '').toString();
      final address = (p['address'] ?? '').toString();
      final nameN    = _norm(name);
      final addressN = _norm(address);

      bool matchSearch = rawQuery.isEmpty;
      if (!matchSearch) {
        matchSearch = expandedTerms.any((term) {
          final termN = _norm(term);
          // Comparaison normalisée (FR) ET brute (AR)
          return nameN.contains(termN) || addressN.contains(termN) ||
                 name.toLowerCase().contains(term.toLowerCase()) ||
                 address.toLowerCase().contains(term.toLowerCase());
        });
      }

      // ── Filtre par type bilingue ──────────────────────────────────
      bool matchType = terms.isEmpty;
      if (!matchType) {
        final rawTypes = p['types'];
        final typeList = rawTypes is List
            ? rawTypes.map((t) => t.toString()).toList()
            : <String>[];
        matchType = typeList.any((t) {
          final tn = _norm(t);
          final tar = t.trim();
          return terms.any((term) => tn.contains(term) || tar.contains(term));
        });
      }

      return matchSearch && matchType;
    }).toList();

    setState(() => _points = filtered);
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Service de localisation désactivé';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission refusée';
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
        _mapController.move(_currentLocation!, 14);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  /// Ouvre Google Maps avec l'itinéraire vers le point de tri
  Future<void> _openGoogleMapsRoute(
    double destLat,
    double destLng,
    String destName,
  ) async {
    // Obtenir la localisation si nécessaire
    if (_currentLocation == null) {
      await _fetchCurrentLocation();
      if (_currentLocation == null) return;
    }

    if (Navigator.canPop(context)) Navigator.pop(context);

    final startLat = _currentLocation!.latitude;
    final startLng = _currentLocation!.longitude;
    final mode = _selectedVehicle.googleMapsMode;

    // URL Google Maps universelle (web + app)
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$startLat,$startLng'
      '&destination=$destLat,$destLng'
      '&travelmode=$mode',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback : schéma geo Android
      final geoUri = Uri.parse('geo:$destLat,$destLng?q=$destLat,$destLng');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible d\'ouvrir Google Maps'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  void _onFilterTap(String key) {
    setState(() => _activeFilter = (key == 'tous') ? null : key);
    _applyFilters();
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _showPointDetails(BuildContext context, Map<String, dynamic> point) {
    // Garde d'authentification : visiteurs non connectés → dialogue de connexion
    if (!AuthState.isLoggedIn) {
      AuthPromptDialog.show(context: context);
      return;
    }
    final types = (point['types'] as List<dynamic>?)?.join(', ') ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.recycling, color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(point['name'] ?? '', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.deepNavy)),
                          ),
                          if (point['is_verified'] == true) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 18),
                          ],
                        ],
                      ),
                      if (point['address'] != null)
                        Text(point['address'], style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(Icons.access_time_rounded, 'Horaires', point['hours'] ?? 'Non spécifié'),
            const SizedBox(height: 10),
            _infoRow(Icons.delete_outline_rounded, 'Déchets acceptés', types.isEmpty ? 'Non spécifié' : types),
            const SizedBox(height: 20),
            // Vehicle selector
            StatefulBuilder(
              builder: (ctx, setModal) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mode de transport',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.deepNavy)),
                    const SizedBox(height: 12),
                    Row(
                      children: VehicleMode.values.map((mode) {
                        final selected = _selectedVehicle == mode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedVehicle = mode);
                              setModal(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? mode.color.withOpacity(0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? mode.color
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(mode.icon,
                                      color: selected
                                          ? mode.color
                                          : Colors.grey.shade400,
                                      size: 26),
                                  const SizedBox(height: 6),
                                  Text(mode.label,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? mode.color
                                              : Colors.grey.shade500)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGoogleMapsRoute(
                  (point['lat'] as num).toDouble(),
                  (point['lng'] as num).toDouble(),
                  point['name'] ?? 'Point de tri',
                ),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Icon(_selectedVehicle.icon, color: Colors.white, size: 18),
                  ],
                ),
                label: Text('OUVRIR DANS GOOGLE MAPS',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedVehicle.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 10),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.deepNavy),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(36.8065, 10.1815),
              initialZoom: 11.5,
              minZoom: 5,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(const LatLng(30.0, 7.0), const LatLng(37.6, 11.6)),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecorewind.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),

              MarkerLayer(
                markers: [
                  ..._points.map((p) => _buildMapMarker(
                    context,
                    LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()),
                    p['name'] ?? '',
                    p['is_verified'] == true,
                    p,
                  )),
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 30)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1.seconds),
                    ),
                ],
              ),
            ],
          ),

          // Loading indicator (premier chargement uniquement - cache vide)
          if (_isLoading)
            Positioned(
              top: 140, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                      const SizedBox(width: 10),
                      Text('Chargement des points...', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
            ),

          // Indicateur de mise à jour silencieuse (cache affiché, refresh en cours)
          if (_isRefreshing && !_isLoading)
            Positioned(
              top: 100, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text('Mise à jour...', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

          // Gradient overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.9), Colors.transparent, Colors.transparent, Colors.white.withOpacity(0.8)],
                  stops: const [0.0, 0.15, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // Search + filters (toujours visible)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearch,
                            onSubmitted: _onSearch,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'بحث / Rechercher un point de tri...',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const Icon(Icons.tune_rounded, color: AppTheme.textMuted, size: 18),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 10),
                  _buildCategories().animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),



          // Results count badge
          if (!_isLoading)
            Positioned(
              bottom: 130, left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRefreshing)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primaryGreen),
                        ),
                      ),
                    Text(
                      '${_points.length} point${_points.length != 1 ? 's' : ''} de tri',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.deepNavy),
                    ),
                  ],
                ),
              ),
            ),

          // Locate me button
          Positioned(
            bottom: 120, right: 24,
            child: FloatingActionButton(
              heroTag: 'fab_map_location',
              onPressed: _fetchCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppTheme.primaryGreen),
            ).animate().scale(delay: 1.seconds),
          ),

          // Refresh button — force un re-téléchargement complet et invalide le cache
          Positioned(
            bottom: 120, left: 24 + 120,
            child: FloatingActionButton.small(
              heroTag: 'fab_map_refresh',
              onPressed: _isRefreshing ? null : () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble(_kCacheVersion, 0.0);
                if (mounted) setState(() => _isRefreshing = true);
                await _fetchAndCachePoints();
                if (mounted) setState(() => _isRefreshing = false);
              },
              backgroundColor: Colors.white,
              child: _isRefreshing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen))
                  : const Icon(Icons.refresh_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _typeMap.length,
        itemBuilder: (context, index) {
          final entry = _typeMap[index];
          final key = entry['key']!;
          final isActive = (key == 'tous' && _activeFilter == null) ||
              (_activeFilter == key);
          return GestureDetector(
            onTap: () => _onFilterTap(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.35),
                        blurRadius: 10, offset: const Offset(0, 4))]
                    : AppTheme.premiumShadow,
                border: Border.all(
                  color: isActive ? AppTheme.primaryGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  entry['fr']!,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                if (key != 'tous') ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 1, height: 12,
                    color: isActive
                        ? Colors.white.withOpacity(0.4)
                        : Colors.grey.shade300,
                  ),
                  Text(
                    entry['ar']!,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white.withOpacity(0.9)
                          : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }

  Marker _buildMapMarker(BuildContext context, LatLng point, String name, bool isVerified, Map<String, dynamic> data) {
    return Marker(
      point: point,
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: () => _showPointDetails(context, data),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.4), blurRadius: 15, spreadRadius: 5)],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.recycling, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepSlate), overflow: TextOverflow.ellipsis)),
                  if (isVerified) const SizedBox(width: 4),
                  if (isVerified) const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 10),
                ],
              ),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: -0.1, duration: 2.seconds),
    );
  }
}
