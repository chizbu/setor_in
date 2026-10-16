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

const LinearGradient kGradientPrimary = LinearGradient(
  colors: [kPrimaryDark, kPrimaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AppTheme {
  AppTheme._();

  static BoxDecoration get greenCardDecoration => BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
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
        iconTheme: IconThemeData(color: kText, size: 24),
        actionsIconTheme: IconThemeData(color: kText, size: 24),
        titleTextStyle: TextStyle(
          color: kText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          fontFamily: 'Nunito',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withValues(alpha: .45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17.2),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.8),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: kBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        hintStyle: const TextStyle(color: kTextSoft, fontSize: 16.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kDanger, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        side: const BorderSide(color: kBorder),
        backgroundColor: kSurface,
        selectedColor: kPrimaryLight,
        labelStyle: const TextStyle(color: kText, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
    );
  }
}
