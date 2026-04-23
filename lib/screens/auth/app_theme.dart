import 'package:flutter/material.dart';

// ── COLORS ────────────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF0D9146); 
const Color kPrimaryDark = Color(0xFF0A7A3A); 
const Color kAccent      = Color(0xFF26D077); 
const Color kInfo        = Color(0xFF3B82F6); 
const Color kWarning     = Color(0xFFF59E0B); 
const Color kDanger      = Color(0xFFEF4444); 

// ── NEUTRALS ──────────────────────────────────────────────────────────────────
const Color kBg           = Color(0xFFF5F7FA); // background utama
const Color kSurface      = Color(0xFFFFFFFF); // card surface
const Color kText         = Color(0xFF1A1A2E); // teks utama
const Color kTextSoft     = Color(0xFF9CA3AF); // teks sekunder / placeholder
const Color kPrimaryLight = Color(0xFFE8F8EF); // hijau muda (badge, chip bg)

// ── GRADIENTS ─────────────────────────────────────────────────────────────────
const LinearGradient kGradientPrimary = LinearGradient(
  colors: [Color(0xFF0D9146), Color(0xFF26D077)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ── APP THEME ─────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  /// Dekorasi card gradient hijau (dipakai di step konfirmasi setor sampah)
  static BoxDecoration get greenCardDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9146), Color(0xFF26D077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );

  /// Dekorasi default untuk card putih dengan shadow halus
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kAccent,
          surface: kSurface,
          background: kBg,
        ),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: kTextSoft, fontSize: 13),
        ),
      );
}