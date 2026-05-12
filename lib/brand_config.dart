import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandColors {
  static const Color primary = Color(0xFFA8D5BA);
  static const Color secondary = Color(0xFF2F2F2F);
  static const Color tertiary = Color(0xFFF0F9F4);
  static const Color neutral = Color(0xFFFFFFFF);
  static const Color natureGreen = Color(0xFF449163);
}

class BrandTypography {
  // headline-lg
  static TextStyle headlineLg = GoogleFonts.sourGummy(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  );

  // headline-md
  static TextStyle headlineMd = GoogleFonts.sourGummy(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
  );

  // body-lg
  static TextStyle bodyLg = GoogleFonts.sourGummy(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
  );

  // body-md
  static TextStyle bodyMd = GoogleFonts.sourGummy(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 24 / 14,
  );

  // label-md
  static TextStyle labelMd = GoogleFonts.sourGummy(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.28, // 0.02em * 14
  );
}

class BrandConfig {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: BrandColors.primary,
      scaffoldBackgroundColor: BrandColors.tertiary,
      textTheme: TextTheme(
        headlineLarge: BrandTypography.headlineLg,
        headlineMedium: BrandTypography.headlineMd,
        bodyLarge: BrandTypography.bodyLg,
        bodyMedium: BrandTypography.bodyMd,
        labelLarge: BrandTypography.labelMd,
      ),
      colorScheme: const ColorScheme.light(
        primary: BrandColors.primary,
        secondary: BrandColors.secondary,
        tertiary: BrandColors.tertiary,
        surface: BrandColors.neutral,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.tertiary,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: BrandTypography.bodyMd.copyWith(
          color: BrandColors.secondary.withValues(alpha: 0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BrandColors.natureGreen, width: 2),
        ),
      ),
    );
  }
}
