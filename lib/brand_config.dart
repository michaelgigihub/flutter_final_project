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
  // headline-lg: Plus Jakarta Sans, 28px, 700, lh 36px
  static TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  );

  // headline-md: Plus Jakarta Sans, 22px, 700, lh 28px
  static TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
  );

  // body-lg: Be Vietnam Pro, 18px, 500, lh 26px
  static TextStyle bodyLg = GoogleFonts.beVietnamPro(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
  );

  // body-md: Be Vietnam Pro, 16px, 400, lh 24px
  static TextStyle bodyMd = GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 24 / 14,
  );

  // label-md: Be Vietnam Pro, 14px, 600, lh 20px, ls 0.02em
  static TextStyle labelMd = GoogleFonts.beVietnamPro(
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
    );
  }
}
