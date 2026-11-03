import 'package:flutter/material.dart';

// Setor.in preview palette: warm paper, forest green, and muted olive accents.
const Color kPrimary = Color(0xFF65784E);
const Color kPrimaryDark = Color(0xFF34422F);
const Color kAccent = Color(0xFFD4B18A);
const Color kInfo = Color(0xFF65784E);
const Color kWarning = Color(0xFFB88C44);
const Color kDanger = Color(0xFF98594F);
const Color kBg = Color(0xFFF2F2E6);
const Color kSurface = Color(0xFFFCFCF5);
const Color kText = Color(0xFF2C3027);
const Color kTextSoft = Color(0xFF85887C);
const Color kPrimaryLight = Color(0xFFE5E7D8);
const Color kBorder = Color(0xFFDDDED2);

/// Shared visual tokens. Keep screen-specific styling on this scale so the
/// mobile experience does not drift through one-off decimal values.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class AppTypography {
  AppTypography._();
  static const double display = 32;
  static const double title = 24;
  static const double section = 20;
  static const double subtitle = 18;
  static const double bodyLarge = 16;
  static const double body = 14;
  static const double bodySmall = 13;
  static const double caption = 12;
  static const double overline = 10;
  static const double button = 14;
}

class AppIconSize {
  AppIconSize._();
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double hero = 48;
}

const LinearGradient kGradientPrimary = LinearGradient(
  colors: [kPrimaryDark, kPrimaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AppTheme {
  AppTheme._();

  static BoxDecoration get greenCardDecoration => BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: kBorder),
      );

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kAccent,
      surface: kSurface,
      error: kDanger,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: scheme,
      scaffoldBackgroundColor: kBg,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: kBg,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        centerTitle: false,
        iconTheme: IconThemeData(color: kText, size: AppIconSize.lg),
        actionsIconTheme: IconThemeData(color: kText, size: AppIconSize.lg),
        titleTextStyle: TextStyle(
          color: kText,
          fontSize: AppTypography.subtitle,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          fontFamily: 'Nunito',
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: AppTypography.display, fontWeight: FontWeight.w800, color: kText),
        headlineSmall: TextStyle(fontSize: AppTypography.title, fontWeight: FontWeight.w800, color: kText),
        titleLarge: TextStyle(fontSize: AppTypography.section, fontWeight: FontWeight.w800, color: kText),
        titleMedium: TextStyle(fontSize: AppTypography.subtitle, fontWeight: FontWeight.w700, color: kText),
        bodyLarge: TextStyle(fontSize: AppTypography.bodyLarge, color: kText),
        bodyMedium: TextStyle(fontSize: AppTypography.body, color: kText),
        bodySmall: TextStyle(fontSize: AppTypography.bodySmall, color: kTextSoft),
        labelLarge: TextStyle(fontSize: AppTypography.button, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: AppTypography.caption, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withValues(alpha: .45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.button),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withValues(alpha: .45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(48, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: AppTypography.button),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: kBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.button),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        hintStyle: const TextStyle(color: kTextSoft, fontSize: AppTypography.body),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: kDanger, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        side: const BorderSide(color: kBorder),
        backgroundColor: kSurface,
        selectedColor: kPrimaryLight,
        labelStyle: const TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: AppTypography.caption),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
    );
  }
}
