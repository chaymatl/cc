import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../theme/web_theme.dart';
import '../models/user_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// WEB SHELL — Sidebar gauche fixe + contenu principal
// Design: dark sidebar premium (Linear / Vercel style)
// ════════════════════════════════════════════════════════════════════════════

class WebShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<Widget> pages;

  const WebShell({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.pages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = AuthState.currentUser?.role ?? UserRole.user;
    final items = _getNavItems(role);

    return Scaffold(
      backgroundColor: WebTheme.bgLight,
      body: Row(
        children: [
          // ── Dark Sidebar ───────────────────────────────────────────────
          _Sidebar(
            items: items,
            currentIndex: currentIndex,
            onItemSelected: onTabSelected,
          ),

          // ── Contenu principal ──────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(currentIndex: currentIndex, items: items),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_NavItem> _getNavItems(UserRole role) {
    if (role == UserRole.educator) {
      return const [
        _NavItem(icon: FontAwesomeIcons.house, label: 'Fil d\'actualités', section: 'PRINCIPAL'),
        _NavItem(icon: FontAwesomeIcons.chalkboardUser, label: 'Éducateur', section: 'ESPACE PRO'),
        _NavItem(icon: FontAwesomeIcons.user, label: 'Profil'),
      ];
    }
    if (role == UserRole.user) {
      return const [
        _NavItem(icon: FontAwesomeIcons.house, label: 'Fil d\'actualités', section: 'PRINCIPAL'),
        _NavItem(icon: FontAwesomeIcons.graduationCap, label: 'Formation'),
        _NavItem(icon: FontAwesomeIcons.chartLine, label: 'Impact', section: 'COMMUNAUTÉ'),
        _NavItem(icon: FontAwesomeIcons.mapLocationDot, label: 'Carte'),
        _NavItem(icon: FontAwesomeIcons.comments, label: 'Communauté'),
        _NavItem(icon: FontAwesomeIcons.user, label: 'Profil', section: 'COMPTE'),
      ];
    }
    return const [
      _NavItem(icon: FontAwesomeIcons.house, label: 'Fil d\'actualités', section: 'PRINCIPAL'),
      _NavItem(icon: FontAwesomeIcons.graduationCap, label: 'Formation'),
      _NavItem(icon: FontAwesomeIcons.chartLine, label: 'Impact', section: 'COMMUNAUTÉ'),
      _NavItem(icon: FontAwesomeIcons.mapLocationDot, label: 'Carte'),
      _NavItem(icon: FontAwesomeIcons.user, label: 'Profil', section: 'COMPTE'),
    ];
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String? section; // label de section (optionnel)
  const _NavItem({required this.icon, required this.label, this.section});
}

// ════════════════════════════════════════════════════════════════════════════
// SIDEBAR — Dark premium (Linear/Vercel style)
// ════════════════════════════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  static const _sidebarBg = Color(0xFF0F172A);
  static const _sidebarBorder = Color(0xFF1E293B);
  static const _sectionLabel = Color(0xFF475569);
  static const _activeGreen = AppTheme.primaryGreen;
  static const _inactiveIcon = Color(0xFF94A3B8);
  static const _inactiveText = Color(0xFFCBD5E1);
  static const _hoverBg = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser;
    final score = user?.points ?? 0;

    return Container(
      width: 252,
      decoration: const BoxDecoration(
        color: _sidebarBg,
        border: Border(right: BorderSide(color: _sidebarBorder)),
      ),
      child: Column(
        children: [
          // ── Logo ──────────────────────────────────────────────────────
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 3),
                  )],
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text('EcoRewind', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.3,
              )),
            ]),
          ),

          Container(height: 1, color: _sidebarBorder),
          const SizedBox(height: 8),

          // ── Navigation ────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (items[i].section != null) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                      child: Text(items[i].section!, style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: _sectionLabel, letterSpacing: 1.2,
                      )),
                    ),
                  ],
                  _NavTile(
                    item: items[i], index: i,
                    isActive: i == currentIndex,
                    onTap: () => onItemSelected(i),
                  ),
                ],
              ],
            ),
          ),

          Container(height: 1, color: _sidebarBorder),

          // ── User card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hoverBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _sidebarBorder),
              ),
              child: Row(children: [
                // Avatar
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentTeal]),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Utilisateur', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text('$score pts', style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
                    ]),
                  ],
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigation Tile ──────────────────────────────────────────────────────────
class _NavTile extends StatefulWidget {
  final _NavItem item;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.index, required this.isActive, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;
  static const _hoverBg = Color(0xFF1E293B);
  static const _activeBg = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active ? _activeBg : (_hovered ? _hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? Border.all(color: AppTheme.primaryGreen.withOpacity(0.25))
                  : null,
            ),
            child: Row(children: [
              // Active indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 3, height: active ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: active ? 10 : 13),
              FaIcon(widget.item.icon, size: 15,
                color: active ? AppTheme.primaryGreen : const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.item.label, style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFFCBD5E1),
                )),
              ),
              if (active)
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen, shape: BoxShape.circle),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TOP BAR — Barre supérieure du contenu principal
// ════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  const _TopBar({required this.currentIndex, required this.items});

  @override
  Widget build(BuildContext context) {
    final user = AuthState.currentUser;
    final pageName = (currentIndex < items.length) ? items[currentIndex].label : '';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        // ── Breadcrumb ────────────────────────────────────────────────
        Row(children: [
          const Icon(Icons.eco_rounded, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Text('EcoRewind', style: GoogleFonts.inter(
            fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1))),
          Text(pageName, style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.deepSlate)),
        ]),

        const Spacer(),

        // ── Notifications ────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
            color: AppTheme.textMuted,
            tooltip: 'Notifications',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ── User chip ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.accentTeal]),
              ),
              child: Center(
                child: Text((user?.name ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ),
            const SizedBox(width: 8),
            Text(user?.name?.split(' ').first ?? 'Utilisateur',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.deepSlate)),
          ]),
        ),
      ]),
    );
  }
}
