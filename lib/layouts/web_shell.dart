import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../theme/web_theme.dart';
import '../models/user_model.dart';

/// Shell web professionnel : sidebar gauche fixe + zone de contenu principale.
/// Design sobre, structuré, sans animations inutiles.
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
          // ── Sidebar ──────────────────────────────────────────────────
          _Sidebar(
            items: items,
            currentIndex: currentIndex,
            onItemSelected: onTabSelected,
          ),

          // ── Divider vertical ─────────────────────────────────────────
          Container(width: 1, color: WebTheme.borderColor),

          // ── Contenu principal ─────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(),
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
        _NavItem(icon: FontAwesomeIcons.house, label: 'Fil d\'actualités'),
        _NavItem(icon: FontAwesomeIcons.chalkboardUser, label: 'Éducateur'),
        _NavItem(icon: FontAwesomeIcons.user, label: 'Profil'),
      ];
    }
    return const [
      _NavItem(icon: FontAwesomeIcons.house, label: 'Fil d\'actualités'),
      _NavItem(icon: FontAwesomeIcons.graduationCap, label: 'Formation'),
      _NavItem(icon: FontAwesomeIcons.chartLine, label: 'Impact'),
      _NavItem(icon: FontAwesomeIcons.mapLocationDot, label: 'Carte'),
      _NavItem(icon: FontAwesomeIcons.user, label: 'Profil'),
    ];
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

/// ── Sidebar gauche ──────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WebTheme.sidebarWidth,
      color: WebTheme.sidebarBg,
      child: Column(
        children: [
          // ── Logo ───────────────────────────────────────────────────
          Container(
            height: WebTheme.topBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ecorewind_logo.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'EcoRewind',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepSlate,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Navigation items ───────────────────────────────────────
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == currentIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onItemSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  hoverColor: AppTheme.primaryGreen.withOpacity(0.04),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? WebTheme.sidebarActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          item.icon,
                          size: 16,
                          color: isActive
                              ? AppTheme.primaryGreen
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppTheme.primaryGreen
                                : AppTheme.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // ── User info en bas ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: WebTheme.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Text(
                    (AuthState.currentUser?.name ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthState.currentUser?.name ?? 'Utilisateur',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AuthState.currentUser?.email ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Top bar web ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: WebTheme.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: WebTheme.bgWhite,
        border: Border(
          bottom: BorderSide(color: WebTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          // Titre page (dynamique)
          Text(
            'Tableau de bord',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepSlate,
            ),
          ),
          const Spacer(),

          // Bouton notifications
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            color: AppTheme.textMuted,
            tooltip: 'Notifications',
          ),

          const SizedBox(width: 8),

          // Avatar utilisateur
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(
              (AuthState.currentUser?.name ?? 'U')[0].toUpperCase(),
              style: GoogleFonts.outfit(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
