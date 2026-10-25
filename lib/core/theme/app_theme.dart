import 'package:flutter/material.dart';

/// AppColors — Centralized color palette mirroring the Mr. Guide web brand
/// (Dark navy theme with bright yellow primary accent).
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A1020); // Dark Navy brand background (~#0A1020)
  static const Color cardSurface = Color(0xFF111B2E); // Card surface (~#111B2E)
  static const Color cardSurfaceLight = Color(0xFF162238); // Elevated card surface
  static const Color navSurface = Color(0xFF0D1728); // Bottom bar / nav surface

  // Borders & Dividers
  static const Color cardBorder = Color(0xFF1F2A40); // Card border (~#1F2A40)
  static const Color cardBorderSubtle = Color(0x1AFFFFFF); // 10% white border
  static const Color cardBorderGlow = Color(0x4DFFCC00); // Yellow glow on highlight

  // Primary Accent (Yellow)
  static const Color primary = Color(0xFFFFCC00); // Bright brand yellow (~#FFCC00)
  static const Color primaryHover = Color(0xFFFFD633);
  static const Color primaryDark = Color(0xFFE5B800);
  static const Color onPrimary = Color(0xFF0A1020); // Dark navy text on yellow

  // Secondary Accents
  static const Color secondaryBlue = Color(0xFF3B6EA5); // Soft blue (~#3B6EA5)
  static const Color secondaryBlueBg = Color(0x2E3B6EA5); // Soft blue tint (~18% opacity)
  static const Color secondaryBlueBorder = Color(0x4D3B6EA5);

  // Status & Dots
  static const Color statusGreen = Color(0xFF22C55E); // Live status green dot
  static const Color statusGreenGlow = Color(0x4D22C55E);
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFFF3F4F6); // Off-white primary text
  static const Color textSecondary = Color(0xFF94A3B8); // Muted blue-grey secondary text
  static const Color textMuted = Color(0xFF64748B); // Muted helper text
  static const Color textGold = Color(0xFFFFCC00); // Brand yellow text highlight

  // Tinted Icon Badges
  static const Color iconBadgeBg = Color(0x24FFCC00); // Yellow at ~14% opacity
  static const Color iconBadgeBorder = Color(0x33FFCC00); // Yellow at ~20% opacity
  static const Color iconBadgeColor = Color(0xFFFFCC00); // Outlined yellow icon

  // Blue Icon Badges (e.g. for Live Trip / secondary tools)
  static const Color iconBadgeBlueBg = Color(0x263B6EA5);
  static const Color iconBadgeBlueBorder = Color(0x403B6EA5);
  static const Color iconBadgeBlueColor = Color(0xFF60A5FA);

  // Glassmorphic Overlays
  static const Color glassWhite = Color(0x1FFFFFFF); // 12% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
}

/// AppRadius — Corner radii scale
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double card = 22.0; // Cards 20-24
  static const double hero = 28.0; // Hero banner 28
  static const double full = 999.0; // Fully rounded pills

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroBorder = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(full));
}

/// AppSpacing — Consistent layout spacing scale (4 / 8 / 12 / 16 / 20 / 24)
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Screen horizontal margins
  static const double screenHorizontal = 18.0; // 16-20
}

/// AppTypography — Headings use elegant serif (Georgia / serif fallback),
/// body and UI elements use clean geometric sans.
class AppTypography {
  AppTypography._();

  static const List<String> serifFallbacks = [
    'Georgia',
    'Playfair Display',
    'Fraunces',
    'Cambria',
    'Times New Roman',
    'serif',
  ];

  // Display (Hero banner headlines)
  static const TextStyle display = TextStyle(
    fontFamilyFallback: serifFallbacks,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  // Headline (Section main titles)
  static const TextStyle headline = TextStyle(
    fontFamilyFallback: serifFallbacks,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.2,
  );

  // Title (Card titles)
  static const TextStyle title = TextStyle(
    fontFamilyFallback: serifFallbacks,
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.25,
  );

  // Title Sans (UI component titles)
  static const TextStyle titleSans = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // Subtitle / Lead
  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Body bold
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body small
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );

  // Eyebrow label (small uppercase, letter-spaced, yellow)
  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 1.8,
    height: 1.2,
  );

  // Highlight phrase (italic yellow serif within headlines)
  static const TextStyle highlightPhrase = TextStyle(
    fontFamilyFallback: serifFallbacks,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}

/// AppTheme — Pre-built ThemeData ready for MaterialApp
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        secondary: AppColors.secondaryBlue,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
