import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'my_app_colors.dart';

class MyAppTheme {
  static TextTheme _googleTextTheme({
    required Brightness brightness,
    required Color onSurface,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;

    // Apply Poppins to the whole text theme, then override your two key styles.
    final themed = GoogleFonts.poppinsTextTheme(base);

    return themed.copyWith(
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: brightness == Brightness.light ? Colors.black87 : Colors.white70,
      ),
    );
  }

  // -------------------- LIGHT --------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: MyAppColors.backgroundLight,

    // Global font + fallback (good for Bangla)
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontFamilyFallback: [
      GoogleFonts.hindSiliguri().fontFamily!,
      // Or: GoogleFonts.notoSansBengali().fontFamily!,
    ],

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: MyAppColors.primary,
      onPrimary: Colors.white,
      secondary: MyAppColors.secondary,
      onSecondary: Colors.white,
      background: MyAppColors.backgroundLight,
      onBackground: Colors.black,
      surface: MyAppColors.surfaceLight,
      onSurface: Colors.black,
      error: MyAppColors.error,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),

    textTheme: _googleTextTheme(
      brightness: Brightness.light,
      onSurface: Colors.black,
    ),
  );

  // -------------------- DARK --------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: MyAppColors.backgroundDark,

    fontFamily: GoogleFonts.poppins().fontFamily,
    fontFamilyFallback: [
      GoogleFonts.hindSiliguri().fontFamily!,
      // Or: GoogleFonts.notoSansBengali().fontFamily!,
    ],

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: MyAppColors.primary,
      onPrimary: Colors.white,
      secondary: MyAppColors.secondary,
      onSecondary: Colors.black,
      background: MyAppColors.backgroundDark,
      onBackground: Colors.white,
      surface: MyAppColors.surfaceDark,
      onSurface: Colors.white,
      error: MyAppColors.error,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black26,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    textTheme: _googleTextTheme(
      brightness: Brightness.dark,
      onSurface: Colors.white,
    ),
  );
}
