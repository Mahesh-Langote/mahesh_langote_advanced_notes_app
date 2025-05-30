import 'package:flutter/material.dart';

/// App color constants following Material Design 3 principles
/// Used throughout the application for consistent theming
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary color palette
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Secondary color palette
  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  // Tertiary color palette
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // Error color palette
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  // Surface color palette
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color surfaceContainer = Color(0xFFF3EDF7);
  static const Color surfaceTint = Color(0xFF6750A4);

  // Background colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);

  // Outline colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Special purpose colors
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onInverseSurface = Color(0xFFF4EFF4);
  static const Color inversePrimary = Color(0xFFD0BCFF);

  // Note-specific colors
  static const Color noteCardBackground = Color(0xFFFFFBFE);
  static const Color noteCardShadow = Color(0x1A000000);
  static const Color categoryChipBackground = Color(0xFFE8DEF8);
  static const Color categoryChipText = Color(0xFF1D192B);

  // Category colors
  static const Color workCategory = Color(0xFF1976D2);
  static const Color personalCategory = Color(0xFF388E3C);
  static const Color ideasCategory = Color(0xFFF57C00);
  static const Color archiveCategory = Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient colors for AppBar
  static const List<Color> appBarGradient = [
    Color(0xFF6750A4),
    Color(0xFF7C4DFF),
  ];

  // Loading and shimmer colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Opacity variants
  static const Color surfaceOpacity12 = Color(0x1F1C1B1F);
  static const Color surfaceOpacity08 = Color(0x141C1B1F);
  static const Color primaryOpacity12 = Color(0x1F6750A4);
  static const Color primaryOpacity08 = Color(0x146750A4);
}
