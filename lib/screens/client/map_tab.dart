import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final AuthService _authService = AuthService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _points = [];
  bool _isLoading = true;
  String? _activeFilter;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isGettingRoute = false;
  
  // Route Info
  String? _routeDistance;
  String? _routeDuration;
  String? _routeDestinationName;

  final List<String> _filters = ['Proximité', 'Plastique', 'Verre', 'Batteries', 'Compost'];

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPoints({String? type, String? search}) async {
    setState(() => _isLoading = true);
    try {
      final points = await _authService.fetchCollectionPoints(type: type, search: search);
      if (mounted) setState(() { _points = points; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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

      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
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

  Future<void> _getRouteToPoint(double destLat, double destLng, String destName) async {
    if (_currentLocation == null) {
      await _fetchCurrentLocation();
      if (_currentLocation == null) return;
    }

    setState(() => _isGettingRoute = true);
    Navigator.pop(context); // Close modal

    try {
      final startLat = _currentLocation!.latitude;
      final startLng = _currentLocation!.longitude;
      final url = 'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$destLng,$destLat?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final coords = route['geometry']['coordinates'] as List;
        
        final distanceMeters = route['distance'] as num;
        final durationSeconds = route['duration'] as num;
        
        String distStr = distanceMeters > 1000 
            ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
            : '${distanceMeters.toInt()} m';
            
        String durStr = durationSeconds > 3600
            ? '${(durationSeconds / 3600).floor()}h ${((durationSeconds % 3600) / 60).round()}min'
            : '${(durationSeconds / 60).round()} min';
        
        setState(() {
          _routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          _routeDistance = distStr;
          _routeDuration = durStr;
          _routeDestinationName = destName;
          _isGettingRoute = false;
        });

        // Fit map bounds to show route
        final bounds = LatLngBounds.fromPoints([_currentLocation!, LatLng(destLat, destLng)]);
        _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)));
      }
    } catch (e) {
      setState(() => _isGettingRoute = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
      _routeDestinationName = null;
    });
    // Re-center on all points or current location
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 12);
    }
  }

  void _onFilterTap(int index) {
    final filter = _filters[index];
    if (index == 0) {
      // "Proximité" = reset filter
      setState(() => _activeFilter = null);
      _loadPoints();
    } else {
      final type = filter.toLowerCase();
      setState(() => _activeFilter = type);
      _loadPoints(type: type);
    }
  }

  void _onSearch(String query) {
    _loadPoints(search: query, type: _activeFilter);
  }

  void _showPointDetails(BuildContext context, Map<String, dynamic> point) {
    final types = (point['types'] as List<dynamic>?)?.join(', ') ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGettingRoute 
                    ? null 
                    : () => _getRouteToPoint((point['lat'] as num).toDouble(), (point['lng'] as num).toDouble(), point['name'] ?? 'Point de tri'),
                icon: _isGettingRoute 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.directions, color: Colors.white),
                label: Text('ITINÉRAIRE', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 10),
        Text('$label : ', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.deepNavy)),
        Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted))),
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
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Border (white)
                    Polyline(
                      points: _routePoints,
                      color: Colors.white,
                      strokeWidth: 8.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    // Inner line (green)
                    Polyline(
                      points: _routePoints,
                      color: AppTheme.primaryGreen,
                      strokeWidth: 4.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
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

          // Loading indicator
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

          // Search + filters
          if (_routePoints.isEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.primaryGreen),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _onSearch,
                              decoration: const InputDecoration(
                                hintText: 'Rechercher un point de tri...',
                                hintStyle: TextStyle(color: AppTheme.textMuted),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const Icon(Icons.tune_rounded, color: AppTheme.textMuted, size: 20),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 16),
                    _buildCategories().animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),

          // Route info overlay
          if (_routePoints.isNotEmpty && _routeDistance != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car_rounded, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Vers ${_routeDestinationName ?? 'Destination'}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepNavy),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_routeDuration • $_routeDistance',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _clearRoute,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
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
                child: Text(
                  '${_points.length} point${_points.length != 1 ? 's' : ''} de tri',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.deepNavy),
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

          // Refresh button
          Positioned(
            bottom: 120, left: 24 + 120,
            child: FloatingActionButton.small(
              heroTag: 'fab_map_refresh',
              onPressed: () => _loadPoints(type: _activeFilter),
              backgroundColor: Colors.white,
              child: const Icon(Icons.refresh_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isActive = (index == 0 && _activeFilter == null) ||
              (index > 0 && _activeFilter == _filters[index].toLowerCase());
          return GestureDetector(
            onTap: () => _onFilterTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
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
