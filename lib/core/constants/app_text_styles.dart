import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double height = 1.5,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Headings
  static final TextStyle h1 = _base(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static final TextStyle h2 = _base(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final TextStyle h3 = _base(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static final TextStyle h4 = _base(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static final TextStyle h5 = _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static final TextStyle h6 = _base(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  // Body
  static final TextStyle bodyLarge = _base(
    fontSize: 16,
    height: 1.5,
  );

  static final TextStyle bodyMedium = _base(
    fontSize: 15,
    height: 1.5,
  );

  static final TextStyle bodySmall = _base(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Labels
  static final TextStyle labelLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static final TextStyle labelMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static final TextStyle labelSmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button - Comforting, readable
  static final TextStyle buttonLarge = _base(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  static final TextStyle buttonMedium = _base(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  static final TextStyle buttonSmall = _base(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  // Caption
  static final TextStyle caption = _base(
    fontSize: 12,
    color: AppColors.textHint,
    height: 1.4,
  );

  // Price
  static final TextStyle priceSmall = _base(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.4,
  );

  static final TextStyle priceMedium = _base(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.4,
  );

  static final TextStyle priceLarge = _base(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.4,
  );

  // Strike-through price
  static final TextStyle priceStrikethrough = _base(
    fontSize: 14,
    color: AppColors.textHint,
    decoration: TextDecoration.lineThrough,
    height: 1.4,
  );

  // Microcopy - Encouraging small text
  static final TextStyle microcopy = _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.4,
  );
}
