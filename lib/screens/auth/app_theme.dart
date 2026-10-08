import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF28734A);
const Color kPrimaryDark = Color(0xFF174B35);
const Color kAccent = Color(0xFF82B879);
const Color kInfo = Color(0xFF426F8D);
const Color kWarning = Color(0xFFC18A32);
const Color kDanger = Color(0xFFB94B45);
const Color kBg = Color(0xFFF5F7F4);
const Color kSurface = Color(0xFFFFFFFF);
const Color kText = Color(0xFF202B25);
const Color kTextSoft = Color(0xFF78847C);
const Color kPrimaryLight = Color(0xFFE7F0E7);
const Color kBorder = Color(0xFFE4EAE4);

const LinearGradient kGradientPrimary = LinearGradient(
  colors: [Color(0xFF174B35), Color(0xFF28734A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AppTheme {
  AppTheme._();

  static BoxDecoration get greenCardDecoration => BoxDecoration(
    gradient: kGradientPrimary,
    borderRadius: BorderRadius.circular(22),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: kSurface,
    borderRadius: BorderRadius.circular(18),
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
      colorScheme: scheme,
      scaffoldBackgroundColor: kBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: kBg,
        foregroundColor: kText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: kText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
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
        hintStyle: const TextStyle(color: kTextSoft, fontSize: 13),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
