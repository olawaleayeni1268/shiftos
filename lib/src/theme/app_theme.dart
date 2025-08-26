import 'package:flutter/material.dart';

class Brand {
  static const indigo = Color(0xFF3949AB);
  static const gold   = Color(0xFFFFC857);
  static const sky    = Color(0xFF90CAF9);
  static const pink   = Color(0xFFF8BBD0);
  static const surface = Color(0xFFFAFAFC);
  static const textPrimary = Color(0xFF13141B);
  static const textMuted   = Color(0xFF8A8FA3);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Brand.indigo,
      scaffoldBackgroundColor: Brand.surface,
      brightness: Brightness.light,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, color: Brand.textPrimary),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600, color: Brand.textPrimary),
      ),
      // ⬇️ Flutter 3.35 expects CardThemeData here
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Brand.surface,
        foregroundColor: Brand.textPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Brand.textPrimary,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        showCheckmark: false,
        side: BorderSide(color: Brand.textMuted.withValues(alpha: 0.15)), // no withOpacity
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Brand.indigo,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class Deco {
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Brand.sky, Brand.pink],
  );
  static const glow = [
    BoxShadow(color: Color(0x3390CAF9), blurRadius: 24, spreadRadius: 2, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x33F8BBD0), blurRadius: 30, spreadRadius: 4, offset: Offset(0, 18)),
  ];
}
