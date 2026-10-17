import 'package:flutter/material.dart';

ThemeData stillframeTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E6B52),
    brightness: brightness,
  ).copyWith(
    surface: light ? const Color(0xFFFFFCF7) : const Color(0xFF221F1B),
    tertiary: light ? const Color(0xFFC4622D) : const Color(0xFFE39A6A),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: light
        ? const Color(0xFFF3EEE4)
        : const Color(0xFF141311),
    appBarTheme: AppBarTheme(
      backgroundColor: light ? const Color(0xFFF3EEE4) : const Color(0xFF141311),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
