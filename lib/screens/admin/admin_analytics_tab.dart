import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'analytics_helpers.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('indicateurs'),
      primary: false,
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        _entete(),
        const SizedBox(height: 20),
        const _SectionUtilisateurs(),
        const _SectionPublications(),
        const _SectionCentres(),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _entete() => Row(children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentTeal]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
    ),
    const SizedBox(width: 14),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TABLEAU DE BORD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
        fontSize: 18, color: AppTheme.deepSlate)),
      Text('Données actualisées en temps réel', style: GoogleFonts.inter(
        fontSize: 12, color: AppTheme.textMuted)),
    ]),
  ]);
}

// ═══════════════════════════════════════════════════
// SECTION UTILISATEURS
// ═══════════════════════════════════════════════════
class _SectionUtilisateurs extends StatefulWidget {
  const _SectionUtilisateurs({Key? key}) : super(key: key);
  @override State<_SectionUtilisateurs> createState() => _EtatUtilisateurs();
}
class _EtatUtilisateurs extends State<_SectionUtilisateurs> {
  String _role = 'Tous';
  int _periode = 30;
  bool _chargement = false;
  List<Map> _parRole = [];
  List<Map> _scores = [];
  Map _apercu = {};
  Timer? _timer;

  static const _roles = ['Tous','user','educator','admin','collector','pointManager'];
  static const _libelles = {'user':'Citoyen','educator':'Éducateur','admin':'Admin','collector':'Collecteur','pointManager':'Gestionnaire'};
  static const _couleurs = {'user':Colors.blue,'educator':Colors.purple,'admin':Colors.red,'collector':Colors.orange,'pointManager':Colors.teal};

  @override void initState() { super.initState(); _charger(); _timer = Timer.periodic(const Duration(seconds: 30), (_) => _charger()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _charger() async {
    if (!mounted) return;
    setState(() => _chargement = true);
    final role = _role == 'Tous' ? '' : _role;
    final r = await Future.wait([
      analyticsGet('/admin/analytics/users/by-role'),
      analyticsGet('/admin/analytics/users/score-distribution?role=$role'),
      analyticsGet('/admin/analytics/overview?role=$role&period_days=$_periode'),
    ]);
    if (!mounted) return;
    setState(() {
      _parRole = (r[0] as List?)?.cast<Map>() ?? [];
      _scores = (r[1] as List?)?.cast<Map>() ?? [];
      _apercu = (r[2] as Map<String,dynamic>?) ?? {};
      _chargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = _apercu['users'] as Map? ?? {};
    final total = (u['total'] as num?)?.toInt() ?? 0;
    final moy = (u['avg_score'] as num?)?.toDouble() ?? 0.0;
    final top = (u['top_scorers'] as List?)?.cast<Map>() ?? [];
    final maxC = _parRole.isEmpty ? 1.0 : _parRole.map((r)=>(r['count'] as num).toDouble()).reduce(math.max);

    return SectionCard(
      titre: 'Utilisateurs & Communauté',
      icone: Icons.people_alt_rounded,
      couleur: Colors.blue,
      chargement: _chargement,
      onActualiser: _charger,
      filtres: [
        FiltreDeroulant(etiquette: 'Rôle', valeur: _role, options: _roles, couleur: Colors.blue,
          onChangement: (v) { setState(() => _role = v); _charger(); }),
        FiltrePeriode(valeur: _periode, couleur: Colors.blue,
          onChangement: (v) { setState(() => _periode = v); _charger(); }),
      ],
      contenu: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPIs
        LayoutBuilder(builder: (_, c) {
          final w = (c.maxWidth - 12) / 2;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '$total', etiquette: 'Utilisateurs actifs',
              sousTitre: 'Comptes inscrits sur la plateforme', icone: Icons.person_rounded, couleur: Colors.blue)),
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '${moy.toStringAsFixed(1)} pts',
              etiquette: 'Score moyen', sousTitre: 'Moyenne communautaire',
              icone: Icons.stars_rounded, couleur: Colors.amber)),
          ]);
        }),
        // Répartition par rôle
        if (_parRole.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Répartition par rôle', style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ..._parRole.map((r) => BarreProgression(
            etiquette: _libelles[r['role']] ?? '${r['role']}',
            valeurTexte: '${r['count']} utilisateurs',
            valeur: (r['count'] as num).toDouble(), max: maxC,
            couleur: _couleurs[r['role']] ?? Colors.grey,
          )),
        ],
        // Distribution scores
        if (_scores.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Distribution des scores', style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          GraphiqueAnneau(
            tranches: _scores.map((b) => MapEntry('${b['bracket']}', (b['count'] as num).toDouble())).toList(),
            couleurs: [Colors.red.shade300, Colors.orange, Colors.amber, Colors.lightGreen, Colors.green],
            etiquettes: _scores.map((b) => '${b['bracket']} pts').toList(),
          ),
        ],
        // Top 3
        if (top.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Meilleurs citoyens', style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ...top.take(3).toList().asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(
                  color: [Colors.amber, Colors.grey.shade400, Colors.brown.shade300][e.key].withOpacity(0.15),
                  shape: BoxShape.circle),
                child: Center(child: Text('${e.key+1}', style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.deepSlate)))),
              const SizedBox(width: 10),
              Expanded(child: Text('${e.value['name']}', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.deepSlate))),
              Text('${e.value['score']} pts', style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w900, color: Colors.amber.shade700)),
            ]),
          )),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════
// SECTION PUBLICATIONS
// ═══════════════════════════════════════════════════
class _SectionPublications extends StatefulWidget {
  const _SectionPublications({Key? key}) : super(key: key);
  @override State<_SectionPublications> createState() => _EtatPublications();
}
class _EtatPublications extends State<_SectionPublications> {
  String _statut = 'Tous';
  bool _chargement = false;
  List<Map> _parStatut = [];
  List<Map> _recentes = [];
  Timer? _timer;

  static const _statuts = ['Tous', 'Publiées', 'En attente', 'Rejetées'];
  static const _statutsApi = {'Publiées':'published','En attente':'pending_review','Rejetées':'rejected'};

  @override void initState() { super.initState(); _charger(); _timer = Timer.periodic(const Duration(seconds: 30), (_) => _charger()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _charger() async {
    if (!mounted) return;
    setState(() => _chargement = true);
    final r = await Future.wait([
      analyticsGet('/admin/analytics/posts/by-status'),
      analyticsGet('/admin/analytics/activity/recent?limit=8'),
    ]);
    if (!mounted) return;
    setState(() {
      _parStatut = (r[0] as List?)?.cast<Map>() ?? [];
      _recentes = (r[1] as List?)?.cast<Map>() ?? [];
      _chargement = false;
    });
  }

  int _compte(String statut) => _parStatut.firstWhere(
    (r) => r['status'] == statut, orElse: () => {'count': 0})['count'] as int? ?? 0;

  @override
  Widget build(BuildContext context) {
    final total = _parStatut.fold<int>(0, (s,r) => s + (r['count'] as int? ?? 0));
    final pub = _compte('published');
    final att = _compte('pending_review');
    final rej = _compte('rejected');

    // Filtrer activité récente selon statut sélectionné
    final filtrApi = _statutsApi[_statut];
    final recFiltrees = filtrApi == null ? _recentes
      : _recentes.where((a) => a['status'] == filtrApi).toList();

    return SectionCard(
      titre: 'Publications & Modération',
      icone: Icons.library_books_rounded,
      couleur: Colors.purple,
      chargement: _chargement,
      onActualiser: _charger,
      filtres: [
        FiltreDeroulant(etiquette: 'Afficher', valeur: _statut, options: _statuts,
          couleur: Colors.purple, onChangement: (v) => setState(() => _statut = v)),
      ],
      contenu: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPIs
        LayoutBuilder(builder: (_, c) {
          final w = (c.maxWidth - 24) / 4;
          return Row(children: [
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '$total',
              etiquette: 'Total', sousTitre: 'Publications',
              icone: Icons.article_rounded, couleur: Colors.purple)),
            const SizedBox(width: 8),
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '$pub',
              etiquette: 'Approuvées', sousTitre: total>0?'${(pub/total*100).toStringAsFixed(0)}% du total':'—',
              icone: Icons.check_circle_rounded, couleur: Colors.green)),
            const SizedBox(width: 8),
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '$att',
              etiquette: 'En attente', sousTitre: att>0?'⚠️ À traiter':'✅ File vide',
              icone: Icons.pending_actions_rounded,
              couleur: att>0?Colors.orange:Colors.green, alerte: att>0)),
            const SizedBox(width: 8),
            SizedBox(width: w, child: IndicateurPrincipal(valeur: '$rej',
              etiquette: 'Rejetées', sousTitre: 'Par IA ou admin',
              icone: Icons.cancel_rounded, couleur: Colors.red)),
          ]);
        }),
        // Anneau
        if (_parStatut.isNotEmpty && (_statut == 'Tous')) ...[
          const SizedBox(height: 20),
          Text('Répartition des publications', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          GraphiqueAnneau(
            tranches: _parStatut.map((r) => MapEntry('${r['status']}', (r['count'] as num).toDouble())).toList(),
            couleurs: const [Colors.green, Colors.orange, Colors.red],
            etiquettes: const ['Approuvées', 'En attente', 'Rejetées'],
          ),
        ],
        // Activité récente
        if (recFiltrees.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Activité récente', style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          ...recFiltrees.map((a) {
            final Color c = a['status']=='published'?Colors.green:a['status']=='pending_review'?Colors.orange:Colors.red;
            final String l = a['status']=='published'?'Approuvé':a['status']=='pending_review'?'En attente':'Rejeté';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text('${a['user']}', style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.deepSlate),
                  overflow: TextOverflow.ellipsis)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(l, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: c))),
                const SizedBox(width: 6),
                Icon(Icons.favorite_rounded, color: Colors.pink.shade200, size: 12),
                const SizedBox(width: 2),
                Text('${a['likes']??0}', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
              ]),
            );
          }),
        ] else if (recFiltrees.isEmpty && _statut != 'Tous')
          Padding(padding: const EdgeInsets.only(top: 16),
            child: Center(child: Text('Aucune publication "$_statut"',
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)))),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════
// SECTION CENTRES DE TRI
// ═══════════════════════════════════════════════════
class _SectionCentres extends StatefulWidget {
  const _SectionCentres({Key? key}) : super(key: key);
  @override State<_SectionCentres> createState() => _EtatCentres();
}
class _EtatCentres extends State<_SectionCentres> {
  String _ville = 'Toutes';
  String _etat = 'Tous';
  String _type = 'Tous';
  bool _chargement = false;
  List<Map> _parVille = [];
  List<Map> _parStatut = [];
  Timer? _timer;

  static const _villes = ['Toutes','Tunis','Nabeul','Sousse','Sfax','Bizerte','Hammamet','Monastir','Ariana','Ben Arous'];
  static const _etats = ['Tous','Disponible','Saturé','Maintenance'];
  static const _types = ['Tous','Plastique','Verre','Papier','Carton','Métal','Électronique','Batteries','Compost','Vêtements','Général'];

  @override void initState() { super.initState(); _charger(); _timer = Timer.periodic(const Duration(seconds: 30), (_) => _charger()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _charger() async {
    if (!mounted) return;
    setState(() => _chargement = true);
    final ville = _ville == 'Toutes' ? '' : _ville;
    final r = await Future.wait([
      analyticsGet('/admin/analytics/centers/by-city'),
      analyticsGet('/admin/analytics/centers/by-status?city=$ville'),
    ]);
    if (!mounted) return;
    final toutesVilles = (r[0] as List?)?.cast<Map>() ?? [];
    setState(() {
      _parVille = _ville == 'Toutes' ? toutesVilles : toutesVilles.where((c) => c['city'] == _ville).toList();
      _parStatut = (r[1] as List?)?.cast<Map>() ?? [];
      _chargement = false;
    });
  }

  // Filtre par état côté client
  List<Map> get _villeFiltree {
    var l = _parVille;
    if (_etat != 'Tous') {
      final etatMap = {'Disponible':'disponible','Saturé':'saturé','Maintenance':'maintenance'};
      final e = etatMap[_etat]!;
      l = l.where((c) => (c[e=='disponible'?'available':e=='saturé'?'saturated':'maintenance'] as int? ?? 0) > 0).toList();
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    // ── KPIs depuis by-status (source unique et fiable) ──
    int statCount(String label) =>
        (_parStatut.firstWhere((r) => (r['status'] as String?) == label,
            orElse: () => {'count': 0})['count'] as num?)?.toInt() ?? 0;
    final dispo = statCount('Disponible');
    final sat   = statCount('Saturé');
    final maint = statCount('Maintenance');
    // total = somme des by-status (cohérent avec le donut)
    final total = dispo + sat + maint;
    final maxT = _villeFiltree.isEmpty ? 1.0 : _villeFiltree.map((c)=>(c['total'] as num).toDouble()).reduce(math.max);

    return SectionCard(
      titre: 'Centres de Tri & Collecte',
      icone: Icons.location_on_rounded,
      couleur: const Color(0xFFF59E0B),
      chargement: _chargement,
      onActualiser: _charger,
      filtres: [
        FiltreDeroulant(etiquette: 'Ville', valeur: _ville, options: _villes,
          couleur: const Color(0xFFF59E0B), onChangement: (v) { setState(() => _ville = v); _charger(); }),
        FiltreDeroulant(etiquette: 'État', valeur: _etat, options: _etats,
          couleur: const Color(0xFFF59E0B), onChangement: (v) => setState(() => _etat = v)),
        // Chips types de déchets (scrollable horizontal)
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final t = _types[i];
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFF59E0B) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? const Color(0xFFF59E0B) : Colors.grey.shade300),
                  ),
                  child: Text(t, style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : Colors.grey.shade700)),
                ),
              );
            },
          ),
        ),
      ],
      contenu: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Stats KPI : 4 cartes en 2x2 ──────────────────────────────
        LayoutBuilder(builder: (_, c) {
          final w = (c.maxWidth - 12) / 2;
          return Column(children: [
            Row(children: [
              SizedBox(width: w, child: IndicateurPrincipal(valeur: '$total',
                etiquette: 'Centres recensés',
                sousTitre: _ville == 'Toutes' ? 'Toutes villes' : _ville,
                icone: Icons.location_on_rounded, couleur: const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              SizedBox(width: w, child: IndicateurPrincipal(valeur: '$dispo',
                etiquette: 'Disponibles',
                sousTitre: total > 0 ? '${(dispo / total * 100).toStringAsFixed(0)}% opérationnels' : '—',
                icone: Icons.check_circle_outline_rounded, couleur: Colors.green)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              SizedBox(width: w, child: IndicateurPrincipal(valeur: '$sat',
                etiquette: 'Saturés',
                sousTitre: sat > 0 ? '⚠️ Intervention requise' : '✅ Aucun saturé',
                icone: Icons.warning_amber_rounded,
                couleur: sat > 0 ? Colors.red : Colors.green, alerte: sat > 0)),
              const SizedBox(width: 12),
              SizedBox(width: w, child: IndicateurPrincipal(valeur: '$maint',
                etiquette: 'En maintenance',
                sousTitre: maint > 0 ? '🔧 $maint centre(s) hors service' : '✅ Aucun',
                icone: Icons.build_circle_outlined,
                couleur: maint > 0 ? Colors.orange : Colors.green, alerte: maint > 0)),
            ]),
          ]);
        }),
        if (_villeFiltree.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Centres par ville', style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ..._villeFiltree.take(8).map((c) {
            final hasSat   = (c['saturated']   as int? ?? 0) > 0;
            final hasMaint = (c['maintenance'] as int? ?? 0) > 0;
            final barColor = hasSat
                ? Colors.red
                : hasMaint
                    ? Colors.orange
                    : const Color(0xFFF59E0B);
            final detail = '${c['available']} dispo'
                + (hasSat   ? ' · ${c['saturated']} sat'   : '')
                + (hasMaint ? ' · ${c['maintenance']} maint' : '');
            return BarreProgression(
              etiquette: '${c['city']}',
              valeurTexte: '${c['total']} ($detail)',
              valeur: (c['total'] as num).toDouble(),
              max: maxT,
              couleur: barColor,
            );
          }),
        ],
        if (_parStatut.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('État des centres${_ville != "Toutes" ? " · $_ville" : ""}',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          () {
            // Ordre et couleurs fixes : Disponible=vert, Saturé=rouge, Maintenance=orange
            const orderDef = [
              {'label': 'Disponible', 'color': Colors.green},
              {'label': 'Saturé',     'color': Colors.red},
              {'label': 'Maintenance','color': Colors.orange},
            ];
            final tranches = orderDef
                .map((def) {
                  final r = _parStatut.firstWhere(
                      (r) => (r['status'] as String?) == def['label'],
                      orElse: () => {'count': 0});
                  return MapEntry(def['label'] as String, (r['count'] as num).toDouble());
                })
                .where((e) => e.value > 0)
                .toList();
            final couleurs = orderDef
                .where((def) {
                  final r = _parStatut.firstWhere(
                      (r) => (r['status'] as String?) == def['label'],
                      orElse: () => {'count': 0});
                  return ((r['count'] as num?) ?? 0) > 0;
                })
                .map((def) => def['color'] as Color)
                .toList();
            final etiquettes = tranches.map((e) => e.key).toList();
            return GraphiqueAnneau(
              tranches: tranches,
              couleurs: couleurs,
              etiquettes: etiquettes,
            );
          }(),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════
// SECTION ENVIRONNEMENT
// ═══════════════════════════════════════════════════
class _SectionEnvironnement extends StatefulWidget {
  const _SectionEnvironnement({Key? key}) : super(key: key);
  @override State<_SectionEnvironnement> createState() => _EtatEnvironnement();
}
class _EtatEnvironnement extends State<_SectionEnvironnement> {
  int _periode = 365;
  bool _chargement = false;
  Map _env = {};
  Timer? _timer;

  @override void initState() { super.initState(); _charger(); _timer = Timer.periodic(const Duration(seconds: 30), (_) => _charger()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _charger() async {
    if (!mounted) return;
    setState(() => _chargement = true);
    final r = await analyticsGet('/admin/analytics/overview?period_days=$_periode');
    if (!mounted) return;
    setState(() {
      _env = (r?['environment'] as Map?) ?? {};
      _chargement = false;
    });
  }

  String _fmt(dynamic v) {
    final n = (v as num?)?.toDouble() ?? 0;
    return n >= 1000 ? '${(n/1000).toStringAsFixed(1)} T' : '${n.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titre: 'Impact Environnemental',
      icone: Icons.eco_rounded,
      couleur: AppTheme.primaryGreen,
      chargement: _chargement,
      onActualiser: _charger,
      filtres: [
        FiltrePeriode(valeur: _periode, couleur: AppTheme.primaryGreen,
          onChangement: (v) { setState(() => _periode = v); _charger(); }),
      ],
      contenu: Column(children: [
        LayoutBuilder(builder: (_, c) {
          final w = (c.maxWidth - 24) / 3;
          return Row(children: [
            SizedBox(width: w, child: IndicateurPrincipal(
              valeur: _fmt(_env['co2_saved_kg']),
              etiquette: 'CO₂ Évité',
              sousTitre: 'Émissions évitées grâce au tri',
              icone: Icons.cloud_done_rounded, couleur: Colors.blueAccent)),
            const SizedBox(width: 12),
            SizedBox(width: w, child: IndicateurPrincipal(
              valeur: _fmt(_env['waste_sorted_kg']),
              etiquette: 'Déchets Triés',
              sousTitre: 'Correctement recyclés',
              icone: Icons.recycling_rounded, couleur: Colors.cyan.shade700)),
            const SizedBox(width: 12),
            SizedBox(width: w, child: IndicateurPrincipal(
              valeur: '${(_env['trees_equivalent'] as num?)?.toInt() ?? 0} 🌳',
              etiquette: 'Arbres Équivalents',
              sousTitre: 'Préservés par la communauté',
              icone: Icons.forest_rounded, couleur: AppTheme.primaryGreen)),
          ]);
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryGreen.withOpacity(0.07), Colors.transparent]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.15)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Ces indicateurs sont calculés à partir de l\'activité réelle de la communauté EcoRewind sur la période sélectionnée.',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, height: 1.5))),
          ]),
        ),
      ]),
    );
  }
}
