import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagme/core/constants/app_colors.dart';

TextTheme _buildTextTheme() {
  final base = GoogleFonts.notoSansTextTheme();
  return base.copyWith(
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
    ),
  );
}

final _elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);

final _segmentedButtonTheme = SegmentedButtonThemeData(
  style: ButtonStyle(
    minimumSize: WidgetStateProperty.all(const Size(0, 40)),
  ),
);

InputDecorationTheme _inputTheme(Color fillColor) => InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

/// Light theme.
ThemeData get appTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.accent,
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputTheme(const Color(0xFFF1F3F4)),
      segmentedButtonTheme: _segmentedButtonTheme,
    );

/// Dark theme.
ThemeData get appDarkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.accent,
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputTheme(const Color(0xFF2C2C2C)),
      segmentedButtonTheme: _segmentedButtonTheme,
    );
