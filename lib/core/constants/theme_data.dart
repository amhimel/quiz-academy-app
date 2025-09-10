import 'package:flutter/material.dart';

import 'my_app_colors.dart';

class MyAppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: MyAppColors.backgroundLight,

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

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      //centerTitle: true,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: MyAppColors.backgroundDark,

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

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black26,
      foregroundColor: Colors.white,
      elevation: 0,
      //centerTitle: true,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
  );
}
