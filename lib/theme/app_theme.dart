import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system for EcoQuest, following a "claymorphism" direction: soft
/// chunky surfaces with a solid bottom edge plus an ambient shadow, thick
/// rounded corners, and a friendly rounded type pairing (Baloo 2 headings
/// over Nunito body). All screens should build their surfaces from
/// [clayDecoration]/[claySurface] instead of ad-hoc BoxDecorations so the
/// whole app keeps the same tactile look.
class AppTheme {
  AppTheme._();

  // Core eco palette.
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color leafGreen = Color(0xFF43A047);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color earthBlue = Color(0xFF1976D2);
  static const Color riverTeal = Color(0xFF00838F);
  static const Color sunshine = Color(0xFFF9A825);
  static const Color quizOrange = Color(0xFFEF8A17);
  static const Color memoryPurple = Color(0xFF7B3FA0);

  /// Warm paper-like backdrop; softer than plain white so clay surfaces pop.
  static const Color cream = Color(0xFFF3F7EC);

  /// Green-tinted near-black used for primary text.
  static const Color ink = Color(0xFF1F3322);

  /// Muted text color for captions and helper copy.
  static const Color fadedInk = Color(0xFF5B6E5D);

  static Color darken(Color color, [double amount = 0.22]) =>
      Color.lerp(color, Colors.black, amount)!;

  static Color lighten(Color color, [double amount = 0.22]) =>
      Color.lerp(color, Colors.white, amount)!;

  /// Chunky clay surface: solid bottom edge + soft ambient shadow + subtle
  /// top highlight, the signature look of every card/button in the app.
  static BoxDecoration clayDecoration({
    required Color surface,
    Color? edge,
    double radius = 24,
    double depth = 5,
    Color? borderColor,
    Gradient? gradient,
  }) {
    final edgeColor = edge ?? darken(surface, 0.28);
    return BoxDecoration(
      color: gradient == null ? surface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.55),
        width: 1.6,
      ),
      boxShadow: [
        BoxShadow(color: edgeColor, offset: Offset(0, depth)),
        BoxShadow(
          color: ink.withValues(alpha: 0.10),
          offset: Offset(0, depth + 7),
          blurRadius: 16,
        ),
      ],
    );
  }

  /// White clay card tinted by [tint] on its bottom edge; the default
  /// container for game content.
  static BoxDecoration claySurface({
    Color tint = primaryGreen,
    double radius = 24,
    double depth = 4,
  }) =>
      clayDecoration(
        surface: Colors.white,
        edge: tint.withValues(alpha: 0.30),
        radius: radius,
        depth: depth,
        borderColor: tint.withValues(alpha: 0.18),
      );

  static TextTheme _textTheme() {
    final headings = GoogleFonts.baloo2TextTheme();
    final body = GoogleFonts.nunitoTextTheme();
    return body
        .copyWith(
          displayLarge: headings.displayLarge,
          displayMedium: headings.displayMedium,
          displaySmall: headings.displaySmall,
          headlineLarge: headings.headlineLarge,
          headlineMedium: headings.headlineMedium,
          headlineSmall: headings.headlineSmall,
          titleLarge: headings.titleLarge,
          titleMedium: headings.titleMedium,
          titleSmall: headings.titleSmall,
        )
        .apply(bodyColor: ink, displayColor: ink);
  }

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
