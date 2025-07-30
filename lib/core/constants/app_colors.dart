import 'package:flutter/material.dart';

/// Farm-inspired color palette for the Crops Ecommerce application
class AppColors {
  // Primary Colors - Deep Forest Green (Trust, nature, growth)
  static const Color primary = Color(0xFF2D5016);
  static const Color primaryLight = Color(0xFF4A7C2A);
  static const Color primaryDark = Color(0xFF1A3009);
  static const Color primaryContainer = Color(0xFFB8E6A3);

  // Secondary Colors - Golden Harvest (Warmth, abundance)
  static const Color secondary = Color(0xFFF4A261);
  static const Color secondaryLight = Color(0xFFF7B885);
  static const Color secondaryDark = Color(0xFFE8944A);
  static const Color secondaryContainer = Color(0xFFFDF2E9);

  // Accent Colors - Fresh Mint (Freshness, vitality)
  static const Color accent = Color(0xFFA8E6CF);
  static const Color accentLight = Color(0xFFC4F0DD);
  static const Color accentDark = Color(0xFF8DDCB8);

  // Background Colors
  static const Color background = Color(0xFFFEFEFE); // Cream White
  static const Color surface = Color(0xFFF0F4EC); // Light Sage
  static const Color surfaceVariant = Color(0xFFE8F0E0);
  static const Color surfaceContainer = Color(0xFFF8FAF6);

  // Text Colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF2D2D2D);
  static const Color onBackground = Color(0xFF1C1C1C);
  static const Color onSurface = Color(0xFF1C1C1C);
  static const Color onSurfaceVariant = Color(0xFF4A4A4A);

  // Semantic Colors
  static const Color error = Color(0xFFE76F51); // Tomato Red
  static const Color errorLight = Color(0xFFED8B73);
  static const Color errorDark = Color(0xFFD85A3F);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF6A994E); // Lettuce Green
  static const Color successLight = Color(0xFF8BB070);
  static const Color successDark = Color(0xFF5A8142);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF2CC8F); // Corn Yellow
  static const Color warningLight = Color(0xFFF5D9A8);
  static const Color warningDark = Color(0xFFEDBF76);
  static const Color onWarning = Color(0xFF2D2D2D);

  static const Color info = Color(0xFF81C784); // Fresh Green
  static const Color infoLight = Color(0xFF9CCC9F);
  static const Color infoDark = Color(0xFF6BB26E);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color neutral = Color(0xFF8E8E8E);
  static const Color neutralLight = Color(0xFFB8B8B8);
  static const Color neutralDark = Color(0xFF6B6B6B);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFCCCCCC);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x26000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x4D000000);
  static const Color overlayDark = Color(0x99000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Category-specific colors
  static const Color vegetables = Color(0xFF4CAF50); // Green
  static const Color fruits = Color(0xFFFF9800); // Orange
  static const Color grains = Color(0xFF8BC34A); // Light Green
  static const Color legumes = Color(0xFF795548); // Brown
  static const Color herbs = Color(0xFF009688); // Teal
  static const Color spices = Color(0xFFFF5722); // Deep Orange
  static const Color rootsAndTubers = Color(0xFF607D8B); // Blue Grey
  static const Color leafyGreens = Color(0xFF2E7D32); // Dark Green

  // Rating Colors
  static const Color ratingFilled = Color(0xFFFFB300); // Amber
  static const Color ratingEmpty = Color(0xFFE0E0E0); // Light Grey

  // Status Colors
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusConfirmed = Color(0xFF2196F3); // Blue
  static const Color statusPreparing = Color(0xFF9C27B0); // Purple
  static const Color statusShipped = Color(0xFF00BCD4); // Cyan
  static const Color statusDelivered = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFFF44336); // Red

  // Utility method to get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return vegetables;
      case 'fruits':
        return fruits;
      case 'grains':
        return grains;
      case 'legumes':
        return legumes;
      case 'herbs':
        return herbs;
      case 'spices':
        return spices;
      case 'roots & tubers':
        return rootsAndTubers;
      case 'leafy greens':
        return leafyGreens;
      default:
        return primary;
    }
  }

  // Utility method to get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'preparing':
        return statusPreparing;
      case 'shipped':
        return statusShipped;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return neutral;
    }
  }
}
