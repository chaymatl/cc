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

  /// Appelé quand on change d'onglet — rafraîchit le profil si nécessaire
  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    // Rafraîchir le score quand on arrive sur l'onglet Profil
    _profileKey.currentState?.refreshScore();
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
      case UserRole.user:
        return [
          const FeedTab(key: ValueKey('feed')),
          const MultimediaTab(key: ValueKey('multimedia')),
          const RewardsTab(key: ValueKey('rewards')),
          const MapTab(key: ValueKey('map')),
          ProfileTab(key: _profileKey),
        ];
      case UserRole.collector:
        return [const CollectorTab(key: ValueKey('collector')), ProfileTab(key: _profileKey)];
      case UserRole.intercommunality:
        return [
          const IntercommunalityTab(key: ValueKey('intercommunality')),
          ProfileTab(key: _profileKey),
        ];
      case UserRole.educator:
        return [const EducatorTab(key: ValueKey('educator')), ProfileTab(key: _profileKey)];
      case UserRole.pointManager:
        return [const PointManagerTab(key: ValueKey('pointmanager')), ProfileTab(key: _profileKey)];
      default:
        return [const FeedTab(key: ValueKey('feed')), ProfileTab(key: _profileKey)];
    }
  }

  List<NavigationDestination> _getDestinations(UserRole role) {
    // Visitor (not logged in) — no Profile tab
    if (!_isLoggedIn) {
      return const [
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.graduationCap, size: 20), label: 'Formation'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine, size: 20), label: 'Impact'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 20), label: 'Carte'),
      ];
    }

    if (role == UserRole.user) {
      return const [
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: 'Fil'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.graduationCap, size: 20), label: 'Formation'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine, size: 20), label: 'Impact'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 20), label: 'Carte'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Profil'),
      ];
    }
    return const [
      NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Tableau de bord'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthState.currentUser?.role ?? UserRole.user;

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
