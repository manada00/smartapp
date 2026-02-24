import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Breadfast-inspired brand palette
  static const Color primary = Color(0xFFAA0082);
  static const Color primaryLight = Color(0xFFC13AA2);
  static const Color primaryDark = Color(0xFF79005D);
  static const Color primarySurface = Color(0xFFFFE9FA);

  static const Color secondary = Color(0xFFFFDB98);
  static const Color secondaryLight = Color(0xFFFFE8C4);
  static const Color secondaryDark = Color(0xFFE7B35D);

  static const Color background = Color(0xFFFFF5E3);
  static const Color backgroundSecondary = Color(0xFFFFF0DB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEBEBEB);
  static const Color surfaceWarm = Color(0xFFFFE9FA);

  static const Color textPrimary = Color(0xFF383838);
  static const Color textSecondary = Color(0xFF5B5B5B);
  static const Color textHint = Color(0xFF808B94);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color divider = Color(0xFFEBEBEB);

  static const Color success = Color(0xFF1F9D61);
  static const Color warning = Color(0xFFE7A90A);
  static const Color error = Color(0xFFD73A49);
  static const Color info = Color(0xFF3B82F6);

  static const Color ratingStar = Color(0xFFE7A90A);

  static const Color scoreExcellent = Color(0xFF1F9D61);
  static const Color scoreGood = Color(0xFF5FC983);
  static const Color scoreMedium = Color(0xFFE7A90A);
  static const Color scoreLow = Color(0xFFE6840D);
  static const Color scoreVeryLow = Color(0xFFD73A49);

  // --- Feeling / Body State Accent Colors ---
  static const Color energyColor = Color(0xFFFFB347);
  static const Color energySurface = Color(0xFFFFE8C4);
  static const Color calmColor = Color(0xFF49B96E);
  static const Color calmSurface = Color(0xFFC6F1D5);
  static const Color focusColor = Color(0xFF6CA8FF);
  static const Color focusSurface = Color(0xFFC8DCFB);
  static const Color digestColor = Color(0xFF62D9C7);
  static const Color digestSurface = Color(0xFFC1F6F0);
  static const Color sleepColor = Color(0xFFB37ADE);
  static const Color sleepSurface = Color(0xFFF3CFFF);
  static const Color fitnessColor = Color(0xFFFF7D6E);
  static const Color fitnessSurface = Color(0xFFFDBDBB);
  static const Color satietyColor = Color(0xFFE7A90A);
  static const Color satietySurface = Color(0xFFFFE9C9);
  static const Color kidsColor = Color(0xFFFF9F7F);
  static const Color kidsSurface = Color(0xFFFFE8C4);
  static const Color fastingColor = Color(0xFF9D7CB8);
  static const Color fastingSurface = Color(0xFFF3CFFF);
  static const Color browseColor = Color(0xFF5F5F5F);
  static const Color browseSurface = Color(0xFFEDFFEF);

  static const Color badgePerfect = Color(0xFF1F9D61);
  static const Color badgeGood = Color(0xFFE7A90A);
  static const Color badgeNotIdeal = Color(0xFFFF7D6E);

  // Loyalty Tier Colors
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFB0B0B0);
  static const Color tierGold = Color(0xFFD4AD30);
  static const Color tierPlatinum = Color(0xFFD8D6D2);

  static const Color orderPending = Color(0xFFE7A90A);
  static const Color orderConfirmed = Color(0xFF3B82F6);
  static const Color orderPreparing = Color(0xFF9D7CB8);
  static const Color orderOutForDelivery = Color(0xFF62D9C7);
  static const Color orderDelivered = Color(0xFF1F9D61);
  static const Color orderCancelled = Color(0xFFD73A49);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFAA0082), Color(0xFFC31399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFDB98), Color(0xFFFFE8C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creamGradient = LinearGradient(
    colors: [Color(0xFFFFF5E3), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFFF5E3), Color(0xFFFFE9FA), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFFFFE8C4), Color(0xFFFFF5E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF383838).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFFAA0082).withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> softGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}
