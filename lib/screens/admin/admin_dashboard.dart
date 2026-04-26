import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import 'add_sorting_center_screen.dart';
import '../../services/auth_service.dart';
import '../client/profile_tab.dart';
import 'user_management_screen.dart';
import 'admin_proposals_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  // Admin stats (loaded from API)
  Map<String, dynamic> _adminStats = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _authService.fetchAdminStats();
    if (mounted) setState(() { _adminStats = stats; _statsLoading = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(Icons.security_rounded, size: 180, color: Colors.white.withOpacity(0.05)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CENTRE DE COMMANDEMENT', 
                            style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text('Supervision Globale', 
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aucune nouvelle notification')),
                  );
                }, 
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
               IconButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'), 
                icon: const Icon(Icons.power_settings_new_rounded, color: AppTheme.errorRed),
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppTheme.primaryGreen,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'VUE D\'ENSEMBLE'),
                Tab(text: 'MODÉRATION'),
                Tab(text: 'CONTENUS'),
                Tab(text: 'PROPOSITIONS'),
                Tab(text: 'POINTS DE TRI'),
                Tab(text: 'UTILISATEURS'),
                Tab(text: 'MON PROFIL'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _PostsModerationTab(onStatsUpdated: _loadStats),
            _buildContentValidationTab(),
            const AdminProposalsScreen(),
            _buildPointsManagementTab(),
            const UserManagementScreen(),
            const ProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      key: const PageStorageKey('admin_overview'),
      primary: false,
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INDICATEURS DE PERFORMANCE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          _buildKpiGrid(),
          const SizedBox(height: 32),
          
          Text('IMPACT ENVIRONNEMENTAL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          _buildImpactSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    String fmt(dynamic v) {
      final n = (v as num?)?.toInt() ?? 0;
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
      return '$n';
    }

    void showKpiDetail(String title, String value, String description, IconData icon, Color color) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 20),
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 42, color: AppTheme.deepSlate)),
              const SizedBox(height: 12),
              Text(description, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text('Fermer', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_statsLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          ));
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              'Utilisateurs', fmt(_adminStats['total_users']),
              '', Icons.group_rounded, Colors.blue, constraints.maxWidth,
              onTap: () => showKpiDetail(
                'UTILISATEURS', fmt(_adminStats['total_users']),
                'Nombre total de comptes inscrits sur la plateforme EcoRewind, incluant citoyens, éducateurs et personnels.',
                Icons.group_rounded, Colors.blue,
              ),
            ),
            _buildSummaryCard(
              'Publications', fmt(_adminStats['total_posts']),
              '', Icons.library_books_rounded, Colors.purple, constraints.maxWidth,
              onTap: () => showKpiDetail(
                'PUBLICATIONS', fmt(_adminStats['total_posts']),
                'Total des publications soumises sur le feed communautaire, tous statuts confondus (publiées, en attente, rejetées).',
                Icons.library_books_rounded, Colors.purple,
              ),
            ),
            _buildSummaryCard(
              'Points de Tri', fmt(_adminStats['total_collection_points']),
              '', Icons.map_rounded, Colors.orange, constraints.maxWidth,
              onTap: () => showKpiDetail(
                'POINTS DE TRI', fmt(_adminStats['total_collection_points']),
                'Nombre de points de collecte référencés et validés sur la carte interactive de EcoRewind.',
                Icons.map_rounded, Colors.orange,
              ),
            ),
            _buildSummaryCard(
              'En attente', fmt(_adminStats['pending_review']),
              '', Icons.pending_actions_rounded,
              (_adminStats['pending_review'] ?? 0) > 0 ? Colors.red : Colors.green,
              constraints.maxWidth,
              onTap: () => showKpiDetail(
                'PUBLICATIONS EN ATTENTE', fmt(_adminStats['pending_review']),
                (_adminStats['pending_review'] ?? 0) > 0
                  ? 'Des publications nécessitent votre validation. Rendez-vous dans l\'onglet MODÉRATION.'
                  : 'Aucune publication en attente. La file de modération est à jour.',
                Icons.pending_actions_rounded,
                (_adminStats['pending_review'] ?? 0) > 0 ? Colors.red : Colors.green,
              ),
            ),
            _buildSummaryCard(
              'Témoignages ⏳', fmt(_adminStats['pending_testimonials']),
              '', Icons.rate_review_rounded,
              (_adminStats['pending_testimonials'] ?? 0) > 0 ? Colors.indigo : Colors.teal,
              constraints.maxWidth,
              onTap: () {
                showKpiDetail(
                  'TÉMOIGNAGES EN ATTENTE', fmt(_adminStats['pending_testimonials']),
                  (_adminStats['pending_testimonials'] ?? 0) > 0
                    ? 'Des témoignages attendent votre validation. Allez dans l\'onglet CONTENUS pour les approuver ou rejeter et les publier sur la page d\'accueil.'
                    : 'Aucun témoignage en attente. Tous les avis ont été traités.',
                  Icons.rate_review_rounded,
                  (_adminStats['pending_testimonials'] ?? 0) > 0 ? Colors.indigo : Colors.teal,
                );
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildSummaryCard(String title, String value, String trend, IconData icon, Color color, double parentWidth, {VoidCallback? onTap}) {
    double width = (parentWidth - 16) / 2;
    final card = Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.tightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
              Text(trend, style: TextStyle(color: trend.startsWith('+') ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.deepSlate)),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  Widget _buildImpactSection() {
    final co2 = (_adminStats['co2_saved_kg'] as num?)?.toDouble() ?? 0;
    final waste = (_adminStats['waste_sorted_kg'] as num?)?.toDouble() ?? 0;
    final trees = (_adminStats['trees_equivalent'] as num?)?.toInt() ?? 0;

    String fmtKg(double v) {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)} T';
      return '${v.toStringAsFixed(1)} kg';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.deepSlate,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        children: [
          _buildImpactRow('CO₂ Évité', _statsLoading ? '...' : fmtKg(co2), Icons.cloud_done_rounded, Colors.blueAccent),
          const Divider(color: Colors.white10, height: 32),
          _buildImpactRow('Déchets Triés', _statsLoading ? '...' : fmtKg(waste), Icons.recycling_rounded, Colors.cyan),
          const Divider(color: Colors.white10, height: 32),
          _buildImpactRow('Arbres Équivalents', _statsLoading ? '...' : '$trees arbres', Icons.forest_rounded, Colors.green),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        const Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
      ],
    );
  }

  Widget _buildContentValidationTab() {
    return _TestimonialsManagementTab();
  }

  Widget _buildPointsManagementTab() {
    return _CollectionPointsManagementTab();
  }

}

// =========================================
// TESTIMONIALS MANAGEMENT TAB
// =========================================

class _TestimonialsManagementTab extends StatefulWidget {
  @override
  State<_TestimonialsManagementTab> createState() => _TestimonialsManagementTabState();
}

class _TestimonialsManagementTabState extends State<_TestimonialsManagementTab> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _testimonials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.authenticatedGet(
        '${AuthService.baseUrl}/admin/testimonials',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> items = data['testimonials'] ?? [];
        if (mounted) setState(() { _testimonials = items.cast<Map<String, dynamic>>(); _isLoading = false; });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveTestimonial(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    await http.put(
      Uri.parse('${AuthService.baseUrl}/admin/testimonials/$id/approve'),
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    );
    _loadTestimonials();
  }

  Future<void> _rejectTestimonial(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    await http.put(
      Uri.parse('${AuthService.baseUrl}/admin/testimonials/$id/reject'),
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    );
    _loadTestimonials();
  }

  Future<void> _toggleFeatured(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    await http.put(
      Uri.parse('${AuthService.baseUrl}/admin/testimonials/$id/feature'),
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    );
    _loadTestimonials();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _testimonials.where((t) => t['is_approved'] != true).toList();
    final approved = _testimonials.where((t) => t['is_approved'] == true).toList();

    return SingleChildScrollView(
      key: const PageStorageKey('admin_testimonials'),
      primary: false,
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TÉMOIGNAGES CITOYENS',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ))
          else ...[
            // Pending
            if (pending.isNotEmpty) ...[
              Text('EN ATTENTE D\'APPROBATION (${pending.length})',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11, color: Colors.orange.shade800)),
              const SizedBox(height: 12),
              ...pending.map((t) => _buildTestimonialCard(t, isPending: true)),
              const SizedBox(height: 32),
            ],

            // Approved
            Text('APPROUVÉS (${approved.length})',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11, color: Colors.green.shade800)),
            const SizedBox(height: 12),
            if (approved.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text('Aucun témoignage approuvé', style: GoogleFonts.inter(color: AppTheme.textMuted))),
              )
            else
              ...approved.map((t) => _buildTestimonialCard(t, isPending: false)),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> t, {required bool isPending}) {
    final stars = t['rating'] ?? 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.tightShadow,
        border: Border.all(color: isPending ? Colors.orange.shade100 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text((t['user_name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['user_name'] ?? 'Anonyme', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, size: 14, color: Colors.amber))),
                  ],
                ),
              ),
              if (t['is_featured'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text('★ Mis en avant', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(t['content'] ?? '', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.deepSlate, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending) ...[
                _actionBtn(Icons.check_circle, Colors.green, 'Approuver', () => _approveTestimonial(t['id'])),
                const SizedBox(width: 8),
                _actionBtn(Icons.cancel, Colors.red, 'Rejeter', () => _rejectTestimonial(t['id'])),
              ] else ...[
                _actionBtn(
                  t['is_featured'] == true ? Icons.star : Icons.star_border,
                  Colors.amber.shade700,
                  t['is_featured'] == true ? 'Retirer' : 'Mettre en avant',
                  () => _toggleFeatured(t['id']),
                ),
                const SizedBox(width: 8),
                _actionBtn(Icons.delete_outline, Colors.red, 'Supprimer', () => _rejectTestimonial(t['id'])),
              ],
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1);
  }

  Widget _actionBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(tooltip, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================
// COLLECTION POINTS MANAGEMENT TAB
// =========================================

class _CollectionPointsManagementTab extends StatefulWidget {
  @override
  State<_CollectionPointsManagementTab> createState() => _CollectionPointsManagementTabState();
}

class _CollectionPointsManagementTabState extends State<_CollectionPointsManagementTab> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _points = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    setState(() => _isLoading = true);
    try {
      final points = await _authService.fetchCollectionPoints();
      if (mounted) setState(() { _points = points; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePoint(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/admin/collection-points/$id'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Point supprimé'), backgroundColor: Colors.green));
      _loadPoints();
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final addressCtrl = TextEditingController(text: existing?['address'] ?? '');
    final latCtrl = TextEditingController(text: existing?['lat']?.toString() ?? '');
    final lngCtrl = TextEditingController(text: existing?['lng']?.toString() ?? '');
    final typesCtrl = TextEditingController(text: (existing?['types'] is List) ? (existing!['types'] as List).join(',') : (existing?['types'] ?? ''));
    final hoursCtrl = TextEditingController(text: existing?['hours'] ?? '');
    String status = existing?['status'] ?? 'disponible';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Ajouter un point' : 'Modifier le point', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Nom', Icons.label),
              _field(addressCtrl, 'Adresse', Icons.location_on),
              Row(children: [
                Expanded(child: _field(latCtrl, 'Latitude', Icons.explore)),
                const SizedBox(width: 8),
                Expanded(child: _field(lngCtrl, 'Longitude', Icons.explore)),
              ]),
              _field(typesCtrl, 'Types (virgule)', Icons.recycling),
              _field(hoursCtrl, 'Horaires', Icons.access_time),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: 'Statut', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                items: ['disponible', 'saturé', 'maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => status = v ?? 'disponible',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              final jwt = prefs.getString('jwt_token');
              final body = json.encode({
                'name': nameCtrl.text,
                'address': addressCtrl.text,
                'lat': latCtrl.text,
                'lng': lngCtrl.text,
                'types': typesCtrl.text,
                'hours': hoursCtrl.text,
                'status': status,
              });
              if (existing == null) {
                await http.post(Uri.parse('${AuthService.baseUrl}/admin/collection-points'),
                  headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'}, body: body);
              } else {
                await http.put(Uri.parse('${AuthService.baseUrl}/admin/collection-points/${existing['id']}'),
                  headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'}, body: body);
              }
              _loadPoints();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: Text(existing == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('admin_points'),
      primary: false,
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RÉSEAU DE COLLECTE (${_points.length})',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: AppTheme.textMuted)),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddSortingCenterScreen()),
                  );
                  if (result != null && result is Map) {
                    final prefs = await SharedPreferences.getInstance();
                    final jwt = prefs.getString('jwt_token');
                    
                    final location = result['location']; // LatLng
                    final latStr = location.latitude.toString();
                    final lngStr = location.longitude.toString();
                    
                    final body = json.encode({
                      'name': result['name'],
                      'lat': latStr,
                      'lng': lngStr,
                      'types': (result['types'] as List).join(', '),
                      'hours': result['hours'],
                      'status': result['status'],
                    });
                    
                    await http.post(
                      Uri.parse('${AuthService.baseUrl}/admin/collection-points'),
                      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'}, 
                      body: body
                    );
                    _loadPoints();
                  }
                },
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('AJOUTER (CARTE)'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IconButton(onPressed: _loadPoints, icon: const Icon(Icons.refresh, color: AppTheme.primaryGreen)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ))
          else if (_points.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucun point de collecte', style: GoogleFonts.inter(color: AppTheme.textMuted)),
            ))
          else
            ..._points.map((p) => _buildPointCard(p)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPointCard(Map<String, dynamic> p) {
    final status = p['status'] ?? 'disponible';
    final statusColor = status == 'disponible' ? Colors.green : (status == 'saturé' ? Colors.red : Colors.orange);
    final load = double.tryParse(p['load_level']?.toString() ?? '0') ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.tightShadow),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.location_on_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(status[0].toUpperCase() + status.substring(1), style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    if (p['address'] != null && p['address'].toString().isNotEmpty)
                      Text(p['address'], style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Modifier')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
                ],
                onSelected: (val) {
                  if (val == 'edit') _showAddEditDialog(existing: p);
                  if (val == 'delete') _deletePoint(p['id']);
                },
              ),
            ],
          ),
          if (load > 0) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: load, backgroundColor: Colors.grey.shade100, color: statusColor, minHeight: 6,
              borderRadius: BorderRadius.circular(3)),
          ],
        ],
      ),
    );
  }
}

// _ValidationItem removed (unused)


// =========================================
// POSTS MODERATION TAB
// =========================================

class _PostsModerationTab extends StatefulWidget {
  final VoidCallback? onStatsUpdated;
  const _PostsModerationTab({this.onStatsUpdated});

  @override
  State<_PostsModerationTab> createState() => _PostsModerationTabState();
}

class _PostsModerationTabState extends State<_PostsModerationTab> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _posts = [];
  int _total = 0;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadPendingPosts();
  }

  Future<void> _loadPendingPosts() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.fetchPendingPosts();
      final moderationStats = await _authService.fetchModerationStats();
      if (mounted) {
        setState(() {
          final raw = result['posts'];
          _posts = raw is List ? raw.cast<Map<String, dynamic>>() : [];
          _total = result['total'] ?? 0;
          _stats = moderationStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(int id) async {
    final ok = await _authService.approvePost(id);
    if (ok) {
      widget.onStatsUpdated?.call();
      _loadPendingPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Publication approuvée'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _reject(int id, String description) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rejeter la publication', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Raison du rejet (optionnel)',
            hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Rejeter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (reason == null) return; // cancelled
    final ok = await _authService.rejectPost(id, reason: reason.isNotEmpty ? reason : null);
    if (ok) {
      widget.onStatsUpdated?.call();
      _loadPendingPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('❌ Publication rejetée'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      onRefresh: _loadPendingPosts,
      child: SingleChildScrollView(
        key: const PageStorageKey('admin_moderation'),
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats bar
            if (_stats.isNotEmpty) ...[
              _buildStatsBar(),
              const SizedBox(height: 24),
            ],

            Row(
              children: [
                Text(
                  _isLoading ? 'CHARGEMENT...' : 'EN ATTENTE ($_total)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, letterSpacing: 1.5,
                    fontSize: 12, color: AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadPendingPosts,
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ))
            else if (_posts.isEmpty)
              _buildEmptyState()
            else
              ..._posts.map((p) => _buildPostCard(p)).toList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final published = _stats['published'] ?? 0;
    final pending = _stats['pending_review'] ?? 0;
    final rejected = _stats['rejected'] ?? 0;
    final total = _stats['total_posts'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip('Publiés', published, Colors.green),
          _statChip('En attente', pending, Colors.amber),
          _statChip('Rejetés', rejected, Colors.red),
          _statChip('Total', total, Colors.white),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green.shade400),
            ),
            const SizedBox(height: 20),
            Text('Tout est à jour !', style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.deepSlate)),
            const SizedBox(height: 6),
            Text('Aucune publication en attente de validation.',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final id = post['id'] as int;
    final userName = post['user_name'] ?? 'Inconnu';
    final description = post['description'] ?? '';
    final imageUrl = post['image_url'] ?? '';
    final score = (post['moderation_score'] as num?)?.toDouble() ?? 0.0;
    final reason = post['moderation_reason'] ?? '';
    final createdAt = post['created_at'] ?? '';

    String fmtDate(String iso) {
      try {
        final dt = DateTime.parse(iso);
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) { return iso; }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.tightShadow,
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (if any)
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                      child: Text(userName[0].toUpperCase(),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(fmtDate(createdAt),
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: score > 0.5 ? Colors.orange.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: score > 0.5 ? Colors.orange.shade200 : Colors.green.shade200),
                      ),
                      child: Text(
                        'Score: ${(score * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: score > 0.5 ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(description, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.deepSlate, height: 1.5),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(child: Text(reason,
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.amber.shade800))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approve(id),
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Approuver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reject(id, description),
                        icon: const Icon(Icons.cancel_rounded, size: 16),
                        label: const Text('Rejeter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }
}
