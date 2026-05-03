import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Thème web professionnel : light, clean, structuré, sobre.
/// Pas d'animations inutiles, pas de glassmorphism, composants Material 3 standards.
class WebTheme {
  // ── Couleurs Web ───────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF1F5F9);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarActive = Color(0xFFECFDF5); // vert très léger

  // Tokens de forme
  static const double cardRadius = 12.0;
  static const double inputRadius = 8.0;
  static const double buttonRadius = 10.0;

  // Sidebar
  static const double sidebarWidth = 260.0;
  static const double topBarHeight = 64.0;

  // Ombres légères (web)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
        boxShadow: cardShadow,
      );

  /// ThemeData complet pour web
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgLight,
        primaryColor: AppTheme.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryGreen,
          primary: AppTheme.primaryGreen,
          secondary: AppTheme.deepSlate,
          surface: bgWhite,
          error: AppTheme.errorRed,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepSlate,
            letterSpacing: -1,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepSlate,
          ),
          titleLarge: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepSlate,
          ),
          titleMedium: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textMain,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textMain,
            side: const BorderSide(color: borderColor),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 1.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          labelStyle: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontSize: 14,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: AppTheme.primaryGreen,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
          space: 0,
        ),
        cardTheme: CardTheme(
          color: bgWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: const BorderSide(color: borderColor),
          ),
        ),
      );
}
