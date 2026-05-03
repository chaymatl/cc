import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'theme/platform_ui.dart';
import 'theme/web_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/marketing_landing_screen.dart';
import 'screens/auth/section_how_it_works.dart';
import 'screens/auth/section_impact.dart';
import 'screens/auth/section_testimonials.dart';
import 'screens/auth/section_advantages.dart';
import 'screens/client/client_home.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/waste_scanner_screen.dart';
import 'screens/client/sorting_guide_screen.dart';
import 'screens/client/bin_scanner_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'models/post_model.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ── Initialisation Firebase (Score temps réel — QR Poubelle) ──────────────
  // Si google-services.json n'est pas encore configuré, l'app continue
  // normalement sans Firebase (pas de crash).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase non configuré ou google-services.json absent — mode dégradé
    debugPrint('[Firebase] Non configuré : $e');
  }

  // Initialiser le SDK Facebook pour le web
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "1420513346522756",
      cookie: true,
      xfbml: true,
      version: "v18.0",
    );
  }
  
  await PostRegistry.loadSavedStates();
  runApp(const EcoRewindApp());
}

class EcoRewindApp extends StatelessWidget {
  const EcoRewindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRewind',
      debugShowCheckedModeBanner: false,
      theme: PlatformUI.isWeb ? WebTheme.theme : AppTheme.seniorTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // ─── Routes d'onglets : chaque onglet = sa propre route ──────────────
        // Transition sans animation pour simuler un vrai changement d'onglet
        Route<dynamic> _tabRoute(int tabIndex) => PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, _, __) =>
                  MainNavigationShell(initialTab: tabIndex),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            );

        switch (settings.name) {
          // Onglet 0 — Fil d'actualités
          case '/home':
          case '/feed':
            final args = settings.arguments as Map<String, dynamic>?;
            final initialTab = args?['initialTab'] as int? ?? 0;
            return _tabRoute(initialTab);

          // Onglet 1 — Formation / Espace pro (éducateur, collecteur, etc.)
          case '/multimedia':
            return _tabRoute(1);

          // Onglet 2 — Impact / Récompenses
          case '/rewards':
            return _tabRoute(2);

          // Onglet 3 — Carte
          case '/map':
            return _tabRoute(3);

          // Onglet Profil — index 2 pour éducateur (3 onglets), 4 pour les autres
          case '/profile':
            final role = AuthState.currentUser?.role ?? UserRole.user;
            return _tabRoute(role == UserRole.educator ? 2 : 4);

          // ─── Routes statiques (avec animation de transition normale) ────────
          case '/':
          case '/marketing':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const MarketingLandingScreen(),
            );
          case '/onboarding':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const OnboardingScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/signup':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SignUpScreen(),
            );
          case '/admin':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AdminDashboardScreen(),
            );
          case '/scanner':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const WasteScannerScreen(),
            );
          case '/guide':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SortingGuideScreen(),
            );
          case '/how-it-works':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SectionHowItWorks(),
            );
          case '/impact':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SectionImpact(),
            );
          case '/testimonials':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SectionTestimonials(),
            );
          case '/advantages':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SectionAdvantages(),
            );
          case '/bin-scanner':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const BinScannerScreen(),
              fullscreenDialog: true,
            );
        }

        return null; // Route inconnue → Flutter affiche une page d'erreur
      },
    );
  }
}
