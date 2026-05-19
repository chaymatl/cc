import 'package:flutter/material.dart';
import '../../widgets/auth_prompt_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user_model.dart';
import 'feed_tab.dart';
import 'map_tab.dart';
import 'rewards_tab.dart';
import 'profile_tab.dart';
import 'multimedia_tab.dart';
import 'community_screen.dart';

import '../admin/collector_tab.dart';
import '../admin/intercommunality_tab.dart';
import '../admin/point_manager_tab.dart';
import '../admin/educator_tab.dart';
import '../../theme/app_theme.dart';
import '../../theme/platform_ui.dart';
import '../../layouts/web_shell.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  late final List<Widget> _pages;
  late final bool _isLoggedIn;


  // GlobalKeys pour accéder aux states des tabs et appeler refresh()
  final GlobalKey<ProfileTabState> _profileKey = GlobalKey<ProfileTabState>();

  @override
  void initState() {
    super.initState();
    _isLoggedIn = AuthState.currentUser != null;
    final role = AuthState.currentUser?.role ?? UserRole.user;
    _pages = _initializePages(role);
    _currentIndex = widget.initialTab.clamp(0, _pages.length - 1);

    if (!_isLoggedIn) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) AuthPromptDialog.show(context: context);
      });
    }
  }


  /// Appelé quand on change d'onglet — simple setState pour conserver l'état des tabs
  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    final role = AuthState.currentUser?.role ?? UserRole.user;
    // Rafraîchir le score quand on arrive sur l'onglet Profil
    final profileIndex = (role == UserRole.educator) ? 2 : (role == UserRole.user ? 5 : 4);
    if (index == profileIndex) _profileKey.currentState?.refreshScore();
    setState(() => _currentIndex = index);
  }

  List<Widget> _initializePages(UserRole role) {
    if (!_isLoggedIn) {
      return [
        const FeedTab(key: ValueKey('feed')),
        const MultimediaTab(key: ValueKey('multimedia')),
        const RewardsTab(key: ValueKey('rewards')),
        const MapTab(key: ValueKey('map')),
      ];
    }

    switch (role) {
      // ── Rôle Éducateur : 3 onglets uniquement (Fil, Éducateur, Profil) ──
      case UserRole.educator:
        return [
          const FeedTab(key: ValueKey('feed')),
          const EducatorTab(key: ValueKey('educator')),
          ProfileTab(key: _profileKey),
        ];

      // ── Rôle Collecteur : même structure, Formation → Espace Collecteur ──
      case UserRole.collector:
        return [
          const FeedTab(key: ValueKey('feed')),
          const CollectorTab(key: ValueKey('collector')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          ProfileTab(key: _profileKey),
        ];

      // ── Rôle Intercommunalité : même structure, Formation → Espace Intercommunalité ──
      case UserRole.intercommunality:
        return [
          const FeedTab(key: ValueKey('feed')),
          const IntercommunalityTab(key: ValueKey('intercommunality')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          ProfileTab(key: _profileKey),
        ];

      // ── Rôle Gestionnaire de point : même structure, Formation → Gestionnaire ──
      case UserRole.pointManager:
        return [
          const FeedTab(key: ValueKey('feed')),
          const PointManagerTab(key: ValueKey('pointmanager')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          ProfileTab(key: _profileKey),
        ];

      // ── Rôle Citoyen (user) : 6 onglets avec Communauté ──
      case UserRole.user:
        return [
          const FeedTab(key: ValueKey('feed')),
          const MultimediaTab(key: ValueKey('multimedia')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          const CommunityScreen(key: ValueKey('community')),
          ProfileTab(key: _profileKey),
        ];

      default:
        return [
          const FeedTab(key: ValueKey('feed')),
          const MultimediaTab(key: ValueKey('multimedia')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          const CommunityScreen(key: ValueKey('community')),
          ProfileTab(key: _profileKey),
        ];
    }
  }

  /// Renvoie le label de l'onglet "Formation" selon le rôle
  String _proTabLabel(UserRole role) {
    switch (role) {
      case UserRole.educator:     return 'Éducateur';
      case UserRole.collector:    return 'Collecte';
      case UserRole.intercommunality: return 'Gestion';
      case UserRole.pointManager: return 'Points';
      default:                    return 'Formation';
    }
  }

  /// Renvoie l'icône de l'onglet "Formation" selon le rôle
  Widget _proTabIcon(UserRole role) {
    switch (role) {
      case UserRole.educator:
        return const FaIcon(FontAwesomeIcons.chalkboardUser, size: 20);
      case UserRole.collector:
        return const Icon(Icons.recycling_rounded, size: 22);
      case UserRole.intercommunality:
        return const Icon(Icons.account_balance_rounded, size: 22);
      case UserRole.pointManager:
        return const Icon(Icons.location_on_rounded, size: 22);
      default:
        return const FaIcon(FontAwesomeIcons.graduationCap, size: 20);
    }
  }

  List<NavigationDestination> _getDestinations(UserRole role) {
    // Visiteur non connecté — pas d'onglet Profil
    if (!_isLoggedIn) {
      return const [
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.graduationCap, size: 20), label: 'Formation'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine, size: 20), label: 'Impact'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 20), label: 'Carte'),
      ];
    }

    // ── Éducateur : 3 onglets (pas d'Impact ni de Carte) ──
    if (role == UserRole.educator) {
      return [
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
        NavigationDestination(icon: _proTabIcon(role), label: _proTabLabel(role)),
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Profil'),
      ];
    }

    // ── Citoyen : 6 onglets avec Communauté ──
    if (role == UserRole.user) {
      return [
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
        NavigationDestination(icon: _proTabIcon(role), label: _proTabLabel(role)),
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine, size: 20), label: 'Impact'),
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 20), label: 'Carte'),
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.comments, size: 20), label: 'Communauté'),
        const NavigationDestination(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Profil'),
      ];
    }

    // Tous les autres rôles connectés : 5 onglets
    return [
      const NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
      NavigationDestination(icon: _proTabIcon(role), label: _proTabLabel(role)),
      const NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine, size: 20), label: 'Impact'),
      const NavigationDestination(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 20), label: 'Carte'),
      const NavigationDestination(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Profil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthState.currentUser?.role ?? UserRole.user;

    // ── Web : sidebar + contenu (professionnel) ──────────────────────
    if (PlatformUI.shouldUseWebLayout(context)) {
      return WebShell(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        pages: _pages,
        isLoggedIn: _isLoggedIn,
      );
    }

    // ── Mobile : bottom navigation premium floating ───────────────────
    final destinations = _getDestinations(role);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        destinations: destinations,
        onTap: (index) {
          _onTabSelected(index);
          if (!_isLoggedIn && mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) AuthPromptDialog.show(context: context);
            });
          }
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PREMIUM FLOATING BOTTOM NAV
// ════════════════════════════════════════════════════════════════════════════
class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = destinations.length;
    final sw = MediaQuery.of(context).size.width - 32; // largeur nette (marges 16*2)
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.07), blurRadius: 36, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: List.generate(count, (i) {
            final dest = destinations[i];
            final active = i == currentIndex;
            final itemW = sw / count;
            return SizedBox(
              width: itemW,
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primaryGreen.withOpacity(0.13) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: active ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: active
                          ? ShaderMask(
                              shaderCallback: (b) => const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentTeal]).createShader(b),
                              child: IconTheme(data: const IconThemeData(color: Colors.white, size: 20), child: dest.icon),
                            )
                          : IconTheme(data: const IconThemeData(color: Color(0xFF64748B), size: 18), child: dest.icon),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: active
                          ? GoogleFonts.outfit(fontSize: count > 4 ? 9.0 : 10.0, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)
                          : GoogleFonts.inter(fontSize: count > 4 ? 8.5 : 9.5, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                        child: Text(dest.label, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
