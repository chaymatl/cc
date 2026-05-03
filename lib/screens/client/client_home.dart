import 'package:flutter/material.dart';
import '../../widgets/auth_prompt_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user_model.dart';
import 'feed_tab.dart';
import 'map_tab.dart';
import 'rewards_tab.dart';
import 'profile_tab.dart';
import 'multimedia_tab.dart';

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
  bool _hasShownAuthPrompt = false;

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
      _hasShownAuthPrompt = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          AuthPromptDialog.show(context: context);
        }
      });
    }
  }

  /// Retourne la route nommée correspondant à l'index d'onglet (role-aware)
  String _routeForIndex(int index) {
    final role = AuthState.currentUser?.role ?? UserRole.user;
    // Éducateur : 3 onglets seulement (Fil=0, Éducateur=1, Profil=2)
    if (role == UserRole.educator) {
      switch (index) {
        case 0: return '/home';
        case 1: return '/multimedia';
        case 2: return '/profile';
        default: return '/home';
      }
    }
    // Tous les autres rôles : 5 onglets
    switch (index) {
      case 0: return '/home';
      case 1: return '/multimedia';
      case 2: return '/rewards';
      case 3: return '/map';
      case 4: return '/profile';
      default: return '/home';
    }
  }

  /// Appelé quand on change d'onglet — met à jour l'index ET la route active
  void _onTabSelected(int index) {
    if (_currentIndex == index) return; // déjà sur cet onglet
    final role = AuthState.currentUser?.role ?? UserRole.user;
    // Rafraîchir le score quand on arrive sur l'onglet Profil
    final profileIndex = (role == UserRole.educator) ? 2 : 4;
    if (index == profileIndex) _profileKey.currentState?.refreshScore();
    // Remplacer la route courante par celle de l'onglet ciblé
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
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

      // ── Rôle Citoyen (user) ──
      case UserRole.user:
        return [
          const FeedTab(key: ValueKey('feed')),
          const MultimediaTab(key: ValueKey('multimedia')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          ProfileTab(key: _profileKey),
        ];

      default:
        return [
          const FeedTab(key: ValueKey('feed')),
          const MultimediaTab(key: ValueKey('multimedia')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
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
        onTabSelected: (index) {
          if (_currentIndex == index) return;
          setState(() => _currentIndex = index);
        },
        pages: _pages,
      );
    }

    // ── Mobile : bottom navigation (Pinterest-like) ──────────────────
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppTheme.primaryGreen.withOpacity(0.1),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen);
                }
                return GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textMuted);
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppTheme.primaryGreen, size: 22);
                }
                return const IconThemeData(color: AppTheme.textMuted, size: 20);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                _onTabSelected(index);
                if (!_isLoggedIn && !_hasShownAuthPrompt) {
                  _hasShownAuthPrompt = true;
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) {
                      AuthPromptDialog.show(context: this.context);
                    }
                  });
                }
              },
              backgroundColor: Colors.white,
              elevation: 0,
              height: 70,
              destinations: _getDestinations(role),
            ),
          ),
        ),
      ),
    );
  }
}
