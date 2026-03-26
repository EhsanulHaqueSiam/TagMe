import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// App theme configured with Material 3 and the UI-SPEC color palette.
ThemeData get appTheme {
  final baseTextTheme = GoogleFonts.notoSansTextTheme();

  final textTheme = baseTextTheme.copyWith(
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    scaffoldBackgroundColor: AppColors.dominant,
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, 40)),
      ),
    ),
  );
}
