import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../widgets/web_back_button.dart';
import '../../services/auth_service.dart';

class AddSortingCenterScreen extends StatefulWidget {
  final Map<String, dynamic>? existingCenter;
  const AddSortingCenterScreen({super.key, this.existingCenter});

  @override
  State<AddSortingCenterScreen> createState() => _AddSortingCenterScreenState();
}

class _AddSortingCenterScreenState extends State<AddSortingCenterScreen> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  final TextEditingController _searchController = TextEditingController();
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late String _selectedStatus;
  bool _isFetchingLocation = false;
  bool _isSearching = false;
  bool _showCoords = false; // toggle manual coords panel
  bool _searchNoResults = false; // aucun résultat trouvé
  String _selectedAddress = ''; // human-readable address of the pinned location
  bool _isReverseGeocoding = false;
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  List<String> _availableTypes = [];
  final Map<String, List<String>> _categorizedTypes = {
    'disponible': [],
    'sature': [],
    'maintenance': []
  };
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCenter;

    _selectedLocation = existing != null && existing['lat'] != null && existing['lng'] != null
        ? LatLng(
            double.tryParse(existing['lat'].toString()) ?? 36.8065,
            double.tryParse(existing['lng'].toString()) ?? 10.1815)
        : const LatLng(36.8065, 10.1815);

    _nameController = TextEditingController(text: existing?['name'] ?? '');
    _hoursController = TextEditingController(text: existing?['hours'] ?? '');
    _latController = TextEditingController(
        text: _selectedLocation.latitude.toStringAsFixed(6));
    _lngController = TextEditingController(
        text: _selectedLocation.longitude.toStringAsFixed(6));

    final String rawStatus =
        existing?['status']?.toString().toLowerCase() ?? 'disponible';
    if (rawStatus == 'disponible') {
      _selectedStatus = 'Disponible';
    } else if (rawStatus == 'saturé') {
      _selectedStatus = 'Saturé';
    } else if (rawStatus == 'maintenance') {
      _selectedStatus = 'Maintenance';
    } else {
      _selectedStatus = 'Disponible';
    }

    if (existing != null &&
        existing['types_detail'] != null &&
        existing['types_detail'] is Map) {
      final detail = existing['types_detail'] as Map<String, dynamic>;
      _categorizedTypes['disponible'] =
          (detail['disponible'] as List?)?.map((e) => e.toString()).toList() ??
              [];
      _categorizedTypes['sature'] =
          (detail['sature'] as List?)?.map((e) => e.toString()).toList() ?? [];
      _categorizedTypes['maintenance'] =
          (detail['maintenance'] as List?)?.map((e) => e.toString()).toList() ??
              [];
    } else if (existing != null && existing['types'] is List) {
      _categorizedTypes['disponible'] =
          (existing['types'] as List).map((e) => e.toString()).toList();
    }

    if (existing == null) {
      // Attendre que le widget soit monté avant de demander la localisation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchExactLocation();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(_selectedLocation, 16);
          _reverseGeocode(_selectedLocation);
        }
      });
    }

    _fetchWasteTypes();
  }

  Future<void> _fetchWasteTypes() async {
    try {
      final response = await http.get(
          Uri.parse('${AuthService.baseUrl}/collection-points/waste-types'));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _availableTypes = data.map((e) => e.toString()).toList();
            _isLoadingTypes = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTypes = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTypes = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _hoursController.dispose();
    _searchController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // ── Update coord controllers when location changes ─────────────────────────
  void _updateCoordsDisplay(LatLng loc) {
    _latController.text = loc.latitude.toStringAsFixed(6);
    _lngController.text = loc.longitude.toStringAsFixed(6);
  }

  // ── Reverse geocode: coords → human address ────────────────────────────────
  Future<void> _reverseGeocode(LatLng loc) async {
    if (_isReverseGeocoding) return;
    setState(() => _isReverseGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json'
        '&lat=${loc.latitude}&lon=${loc.longitude}&zoom=17&addressdetails=1&accept-language=fr',
      );
      final res = await http.get(uri, headers: {'User-Agent': 'EcoRewindApp/1.0'});
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        final parts = [
          addr['road'] ?? addr['pedestrian'] ?? addr['quarter'],
          addr['suburb'] ?? addr['neighbourhood'],
          addr['city'] ?? addr['town'] ?? addr['village'],
        ].whereType<String>().where((s) => s.isNotEmpty).toList();
        final label = parts.isNotEmpty
            ? parts.join(', ')
            : (data['display_name']?.toString() ?? '');
        if (mounted) setState(() => _selectedAddress = label);
      }
    } catch (_) {}
    if (mounted) setState(() => _isReverseGeocoding = false);
  }

  // ── Apply manually entered coordinates ────────────────────────────────────
  void _applyManualCoords() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coordonnées invalides'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final newLoc = LatLng(lat, lng);
    setState(() => _selectedLocation = newLoc);
    _mapController.move(newLoc, 16);
    _updateCoordsDisplay(newLoc);
    _reverseGeocode(newLoc);
    FocusScope.of(context).unfocus();
  }

  Future<void> _fetchExactLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Le service de localisation est désactivé.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permissions de localisation refusées.';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        final loc = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedLocation = loc;
          _isFetchingLocation = false;
        });
        _updateCoordsDisplay(loc);
        _mapController.move(loc, 17);
        _reverseGeocode(loc);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.isEmpty) {
      setState(() { _searchResults = []; _searchNoResults = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.length >= 2) {
        _searchLocation(query);
      } else {
        setState(() { _searchResults = []; _searchNoResults = false; });
      }
    });
  }

  Future<void> _searchLocation(String query) async {
    if (!mounted) return;
    setState(() { _isSearching = true; _searchNoResults = false; });

    final trimmed = query.trim();
    List<dynamic> results = [];

    // ── Étape 1 : Photon (komoot) — API gratuite, pas de rate-limit, OSM-based ──
    try {
      // Centre de la Tunisie pour biaiser les résultats
      final photonUri = Uri.parse(
          'https://photon.komoot.io/api/'
          '?q=${Uri.encodeComponent(trimmed)}'
          '&lang=fr&limit=10&lat=33.8&lon=9.5');
      final resp = await http
          .get(photonUri, headers: {'User-Agent': 'EcoRewindApp/1.0'})
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (resp.statusCode == 200) {
        // Photon retourne du GeoJSON → convertir au format Nominatim
        final geojson = json.decode(resp.body) as Map<String, dynamic>;
        final features = geojson['features'] as List<dynamic>? ?? [];
        // Filtrer sur la Tunisie d'abord
        final tnFeatures = features.where((f) {
          final props = f['properties'] as Map<String, dynamic>? ?? {};
          return props['country_code']?.toString().toLowerCase() == 'tn';
        }).toList();
        // Si pas de résultats TN, prendre tous les résultats
        final toConvert = tnFeatures.isNotEmpty ? tnFeatures : features;
        results = toConvert.map((f) {
          final props = f['properties'] as Map<String, dynamic>? ?? {};
          final coords = (f['geometry']['coordinates'] as List<dynamic>);
          final lon = coords[0];
          final lat = coords[1];
          // Construire un display_name lisible
          final parts = [
            props['name'],
            props['street'],
            props['city'] ?? props['town'] ?? props['village'],
            props['state'],
            props['country'],
          ].whereType<String>().where((s) => s.isNotEmpty).toList();
          return {
            'lat': lat.toString(),
            'lon': lon.toString(),
            'display_name': parts.join(', '),
            'place_id': '${lat}_$lon',
            'address': {
              'road': props['street'],
              'city': props['city'] ?? props['town'] ?? props['village'],
              'state': props['state'],
              'country': props['country'],
              'amenity': props['name'],
            },
            'type': props['type'] ?? 'place',
            'class': props['osm_type'] ?? 'place',
          };
        }).toList();
      }
    } catch (_) {}

    // ── Étape 2 : Nominatim fallback (si Photon vide) ──
    if (results.isEmpty && mounted) {
      try {
        final nomUri = Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json'
            '&q=${Uri.encodeComponent(trimmed)}&limit=10'
            '&addressdetails=1&accept-language=fr'
            '&countrycodes=tn');
        final nomResp = await http
            .get(nomUri, headers: {'User-Agent': 'EcoRewindApp/1.0 contact@ecorewind.app'})
            .timeout(const Duration(seconds: 12));

        if (!mounted) return;

        if (nomResp.statusCode == 200) {
          results = json.decode(nomResp.body);
        }
      } catch (_) {}
    }

    // ── Étape 3 : Nominatim mondial (dernier recours) ──
    if (results.isEmpty && mounted) {
      try {
        final nomUri2 = Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json'
            '&q=${Uri.encodeComponent(trimmed)}&limit=6'
            '&addressdetails=1&accept-language=fr');
        final nomResp2 = await http
            .get(nomUri2, headers: {'User-Agent': 'EcoRewindApp/1.0 contact@ecorewind.app'})
            .timeout(const Duration(seconds: 12));

        if (!mounted) return;

        if (nomResp2.statusCode == 200) {
          results = json.decode(nomResp2.body);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _searchNoResults = results.isEmpty;
      });
    }
  }

  void _selectSearchResult(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final newLocation = LatLng(lat, lon);

    // Build a short name from Nominatim address fields
    final address = result['address'] as Map<String, dynamic>? ?? {};
    final shortName = address['amenity'] ??
        address['leisure'] ??
        address['shop'] ??
        address['building'] ??
        address['road'] ??
        result['display_name']?.toString().split(',').first.trim() ??
        '';

    // Build readable address from Nominatim addressdetails
    final addrParts = [
      address['road'] ?? address['pedestrian'] ?? address['quarter'],
      address['suburb'] ?? address['neighbourhood'],
      address['city'] ?? address['town'] ?? address['village'],
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
    final readableAddr = addrParts.isNotEmpty
        ? addrParts.join(', ')
        : result['display_name']?.toString() ?? '';

    setState(() {
      _selectedLocation = newLocation;
      _searchResults = [];
      _searchController.clear();
      _selectedAddress = readableAddr;
      // Auto-fill name only when field is still empty
      if (_nameController.text.isEmpty && shortName.isNotEmpty) {
        _nameController.text = shortName;
      }
      FocusScope.of(context).unfocus();
    });

    _updateCoordsDisplay(newLocation);
    _mapController.move(newLocation, 17);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _selectedAddress = ''; // reset while geocoding
    });
    _updateCoordsDisplay(point);
    _reverseGeocode(point);
  }

  void _copyCoords() {
    final text =
        '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 Coordonnées copiées : $text'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveNewCenter() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez entrer un nom pour le centre'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'types': jsonEncode(_categorizedTypes),
      'hours': _hoursController.text.trim(),
      'status': _selectedStatus.toLowerCase(),
      'location': _selectedLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: webLeading(IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppTheme.deepNavy, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        )),
        title: Text(
          widget.existingCenter == null ? 'Ajouter un Point' : 'Modifier le Point',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppTheme.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Toggle manual coords entry
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _showCoords
                    ? AppTheme.primaryGreen.withOpacity(0.2)
                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.pin_drop_rounded,
                  color: _showCoords ? AppTheme.primaryGreen : AppTheme.textMuted,
                  size: 20),
            ),
            tooltip: 'Saisir des coordonnées manuellement',
            onPressed: () => setState(() => _showCoords = !_showCoords),
          ),
          if (_isFetchingLocation)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.primaryGreen),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                tooltip: 'Ma position actuelle',
                onPressed: _fetchExactLocation,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── 1. Interactive Map ───────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                // ESRI ArcGIS World Street Map — gratuit, sans clé, CDN mondial
                // IMPORTANT: ESRI utilise {z}/{y}/{x} (y avant x), pas {z}/{x}/{y}
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.ecorewind.app',
                tileProvider: CancellableNetworkTileProvider(),
                // Fallback : ESRI World Imagery (photos satellite)
                fallbackUrl:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint('[Map] Tile error at ${tile.coordinates}: $error');
                },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 70,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                      size: 50,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.15, 1.15),
                          duration: 1.seconds,
                        ),
                  ),
                ],
              ),
            ],
          ), // FlutterMap

          // ── 2. Zoom controls (right side) ────────────────────────────────────
          Positioned(
            right: 12,
            bottom: screenHeight * 0.48 + 8,
            child: Column(
              children: [
                _zoomButton(Icons.add, () => _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom + 1).clamp(3, 19))),
                const SizedBox(height: 6),
                _zoomButton(Icons.remove, () => _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom - 1).clamp(3, 19))),
              ],
            ),
          ),

          // ── 3. Address bar + GPS chip above bottom sheet ─────────────────────
          Positioned(
            bottom: screenHeight * 0.46 + 4,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Address label
                if (_isReverseGeocoding)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primaryGreen)),
                      const SizedBox(width: 8),
                      Text('Recherche de l\'adresse...', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                    ]),
                  )
                else if (_selectedAddress.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.place_rounded, size: 13, color: AppTheme.primaryGreen),
                      const SizedBox(width: 6),
                      Flexible(child: Text(
                        _selectedAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.deepNavy),
                      )),
                    ]),
                  ),
                const SizedBox(height: 6),
                // GPS coordinates chip
                GestureDetector(
                  onTap: _copyCoords,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.gps_fixed_rounded, size: 12, color: AppTheme.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedLocation.latitude.toStringAsFixed(5)},  ${_selectedLocation.longitude.toStringAsFixed(5)}',
                        style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.deepNavy),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.copy_rounded, size: 11, color: AppTheme.textMuted.withOpacity(0.7)),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. Bottom Details Sheet ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: bottomInsets > 0
                        ? (screenHeight - bottomInsets - kToolbarHeight - 60)
                            .clamp(180.0, 380.0)
                        : screenHeight * 0.46,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withOpacity(0.96)
                        : Colors.white.withOpacity(0.94),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border(
                        top: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withOpacity(0.06),
                            width: 1.5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, -10))
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // drag handle
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            'DÉTAILS DU CENTRE',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── Name field ──────────────────────────────────────
                          TextField(
                            controller: _nameController,
                            style: GoogleFonts.inter(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 14),
                            cursorColor: const Color(0xFF00BFA6),
                            decoration: InputDecoration(
                              hintText: 'Nom du centre (ex: Tunis Nord)',
                              hintStyle: GoogleFonts.inter(
                                  color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.edit_note_rounded,
                                  color: AppTheme.primaryGreen),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Hours field ─────────────────────────────────────
                          TextField(
                            controller: _hoursController,
                            style: GoogleFonts.inter(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 14),
                            cursorColor: const Color(0xFF00BFA6),
                            decoration: InputDecoration(
                              hintText: 'Horaires (ex: 8h-18h)',
                              hintStyle: GoogleFonts.inter(
                                  color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.access_time_rounded,
                                  color: AppTheme.primaryGreen),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),

                          // ── Manual coordinates panel (toggle) ───────────────
                          if (_showCoords) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppTheme.primaryGreen.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.pin_drop_rounded,
                                        size: 14, color: AppTheme.primaryGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      'COORDONNÉES GPS',
                                      style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                          color: AppTheme.primaryGreen),
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _latController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                            signed: true, decimal: true),
                                        style: GoogleFonts.robotoMono(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : AppTheme.deepNavy),
                                        decoration: InputDecoration(
                                          labelText: 'Latitude',
                                          labelStyle: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textMuted),
                                          filled: true,
                                          fillColor: isDark
                                              ? const Color(0xFF0F172A)
                                              : Colors.white,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _lngController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                            signed: true, decimal: true),
                                        style: GoogleFonts.robotoMono(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : AppTheme.deepNavy),
                                        decoration: InputDecoration(
                                          labelText: 'Longitude',
                                          labelStyle: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textMuted),
                                          filled: true,
                                          fillColor: isDark
                                              ? const Color(0xFF0F172A)
                                              : Colors.white,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _applyManualCoords,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _copyCoords,
                                    child: Row(children: [
                                      Icon(Icons.copy_rounded,
                                          size: 12,
                                          color: AppTheme.primaryGreen
                                              .withOpacity(0.7)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copier les coordonnées',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.8)),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('CLASSIFICATION DES DÉCHETS',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      fontSize: 11,
                                      color: AppTheme.textMuted)),
                              Text("(Cliquez pour changer l'état)",
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_isLoadingTypes)
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primaryGreen)))
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableTypes.map((type) {
                                String state = 'none';
                                if (_categorizedTypes['disponible']!
                                    .contains(type)) {
                                  state = 'disponible';
                                } else if (_categorizedTypes['sature']!
                                    .contains(type)) {
                                  state = 'sature';
                                } else if (_categorizedTypes['maintenance']!
                                    .contains(type)) {
                                  state = 'maintenance';
                                }

                                Color color = Colors.grey.shade400;
                                Color bgColor = Colors.transparent;
                                IconData? icon;

                                if (state == 'disponible') {
                                  color = Colors.green;
                                  bgColor = Colors.green.withOpacity(0.15);
                                  icon = Icons.check_circle;
                                } else if (state == 'sature') {
                                  color = Colors.red;
                                  bgColor = Colors.red.withOpacity(0.15);
                                  icon = Icons.warning_rounded;
                                } else if (state == 'maintenance') {
                                  color = Colors.orange;
                                  bgColor = Colors.orange.withOpacity(0.15);
                                  icon = Icons.build_circle;
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _categorizedTypes['disponible']!
                                          .remove(type);
                                      _categorizedTypes['sature']!
                                          .remove(type);
                                      _categorizedTypes['maintenance']!
                                          .remove(type);

                                      if (state == 'none') {
                                        _categorizedTypes['disponible']!
                                            .add(type);
                                      } else if (state == 'disponible') {
                                        _categorizedTypes['sature']!.add(type);
                                      } else if (state == 'sature') {
                                        _categorizedTypes['maintenance']!
                                            .add(type);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      border: Border.all(
                                          color: state == 'none'
                                              ? (isDark
                                                  ? Colors.white24
                                                  : Colors.grey.shade300)
                                              : color,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (icon != null) ...[
                                          Icon(icon, size: 14, color: color),
                                          const SizedBox(width: 4)
                                        ],
                                        Text(type,
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: state == 'none'
                                                    ? (isDark
                                                        ? Colors.grey.shade300
                                                        : Colors.grey.shade600)
                                                    : color,
                                                fontWeight: state != 'none'
                                                    ? FontWeight.bold
                                                    : FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildStatusChip(
                                      'Disponible', Colors.green)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      _buildStatusChip('Saturé', Colors.red)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildStatusChip(
                                      'Maintenance', Colors.orange)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PremiumButton(
                            text: widget.existingCenter == null
                                ? "CONFIRMER L'AJOUT"
                                : 'ENREGISTRER',
                            onPressed: _saveNewCenter,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

          // ── 4. Search Bar Overlay ────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Search input ──────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withOpacity(0.95)
                            : Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: _searchController.text.isNotEmpty
                                ? AppTheme.primaryGreen.withOpacity(0.5)
                                : (isDark ? Colors.white12 : Colors.black12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) {
                          if (v.length >= 2) _searchLocation(v);
                        },
                        style: GoogleFonts.inter(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 14),
                        cursorColor: AppTheme.primaryGreen,
                        decoration: InputDecoration(
                          hintText: 'Rechercher : Nabeul, Sousse, Tunis...',
                          hintStyle: GoogleFonts.inter(
                              color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppTheme.primaryGreen),
                                    ),
                                  )
                                : const Icon(Icons.search_rounded,
                                    color: AppTheme.primaryGreen, size: 22),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 20, color: AppTheme.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _searchNoResults = false;
                                    });
                                  },                                )
                              : null,
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Résultats de recherche ──────────────────────────────────
                if (_searchResults.isNotEmpty || _searchNoResults)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: BoxConstraints(
                          maxHeight:
                              (screenHeight * 0.38).clamp(140.0, 300.0),
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withOpacity(0.97)
                              : Colors.white.withOpacity(0.97),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _searchNoResults
                            // ── Aucun résultat ──────────────────────────────
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 16),
                                child: Row(children: [
                                  Icon(Icons.search_off_rounded,
                                      color: AppTheme.textMuted, size: 20),
                                  const SizedBox(width: 10),
                                  Flexible(child: Text(
                                    'Aucun résultat pour "${_searchController.text}"',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textMuted),
                                  )),
                                ]),
                              )
                            // ── Liste des résultats ─────────────────────────
                            : ListView.separated(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                itemCount: _searchResults.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  indent: 48,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  final addr =
                                      result['address'] as Map<String, dynamic>? ??
                                          {};
                                  final displayName =
                                      result['display_name']?.toString() ?? '';
                                  final parts = displayName.split(',');

                                  // Titre : nom du lieu
                                  final title = parts.first.trim();

                                  // Sous-titre : ville / gouvernorat / pays
                                  final cityPart = addr['city'] ??
                                      addr['town'] ??
                                      addr['village'] ??
                                      addr['county'];
                                  final statePart =
                                      addr['state'] ?? addr['region'];
                                  final countryPart = addr['country'];
                                  final subtitleParts = [
                                    cityPart,
                                    statePart,
                                    countryPart,
                                  ]
                                      .whereType<String>()
                                      .where((s) => s.isNotEmpty)
                                      .toList();
                                  final subtitle = subtitleParts.isNotEmpty
                                      ? subtitleParts.join(', ')
                                      : (parts.length > 1
                                          ? parts
                                              .sublist(1)
                                              .take(2)
                                              .map((e) => e.trim())
                                              .join(', ')
                                          : '');

                                  // Icône selon type de lieu
                                  final type =
                                      result['type']?.toString() ?? '';
                                  final osmClass =
                                      result['class']?.toString() ?? '';
                                  IconData placeIcon =
                                      Icons.location_on_rounded;
                                  Color iconColor = AppTheme.primaryGreen;
                                  if (osmClass == 'amenity') {
                                    placeIcon = Icons.place_rounded;
                                  } else if (osmClass == 'highway' ||
                                      type == 'residential' ||
                                      type == 'road') {
                                    placeIcon = Icons.signpost_rounded;
                                    iconColor = Colors.blueGrey;
                                  } else if (osmClass == 'boundary' ||
                                      type == 'administrative') {
                                    placeIcon = Icons.location_city_rounded;
                                    iconColor = Colors.deepPurple;
                                  } else if (osmClass == 'natural') {
                                    placeIcon = Icons.terrain_rounded;
                                    iconColor = Colors.green;
                                  }

                                  return InkWell(
                                    onTap: () => _selectSearchResult(result),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: iconColor.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(placeIcon,
                                              size: 18, color: iconColor),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF1E293B),
                                                ),
                                              ),
                                              if (subtitle.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  subtitle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: AppTheme.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                            Icons.north_west_rounded,
                                            size: 14,
                                            color: AppTheme.textMuted),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
        ),
        child: Icon(icon, size: 20,
            color: isDark ? Colors.white : AppTheme.deepNavy),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.transparent : color.withOpacity(0.2)),
        ),
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
