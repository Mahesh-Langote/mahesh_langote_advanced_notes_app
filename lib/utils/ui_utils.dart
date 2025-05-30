import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Utility class for responsive design helpers
/// Provides methods to adapt UI based on screen size
class ResponsiveUtils {
  ResponsiveUtils._(); // Private constructor to prevent instantiation

  /// Check if the screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppSizes.mobileBreakpoint;
  }

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppSizes.mobileBreakpoint &&
        width < AppSizes.tabletBreakpoint;
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppSizes.desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppSizes.paddingM);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppSizes.paddingL);
    } else {
      return const EdgeInsets.all(AppSizes.paddingXL);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppSizes.spaceM);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppSizes.spaceL);
    } else {
      return const EdgeInsets.all(AppSizes.spaceXL);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
      BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize;
    } else if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.4;
    }
  }

  /// Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive SliverAppBar height
  static double getSliverAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return AppSizes.sliverAppBarExpandedHeight;
    } else {
      return AppSizes.sliverAppBarExpandedHeight * 1.2;
    }
  }

  /// Get responsive max width for centered content
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return AppSizes.tabletBreakpoint;
    } else {
      return AppSizes.desktopBreakpoint * 0.8;
    }
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isMobile(context)) {
      return AppSizes.cardElevation;
    } else {
      return AppSizes.cardElevation * 1.5;
    }
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is open
  static bool isKeyboardOpen(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get screen orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if portrait orientation
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Check if landscape orientation
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }
}

/// Utility class for UI helpers
/// Provides common UI operations and calculations
class UIUtils {
  UIUtils._(); // Private constructor to prevent instantiation

  /// Show a snackbar with custom styling
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? AppColors.onSurface),
        ),
        backgroundColor: backgroundColor ?? AppColors.surface,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? AppColors.error,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, [String? message]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppSizes.spaceM),
            Text(message ?? AppStrings.loading),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Get text style for category chip
  static TextStyle getCategoryChipTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: AppColors.categoryChipText,
          fontWeight: FontWeight.w500,
        );
  }

  /// Get color for category
  static Color getCategoryColor(String? category) {
    if (category == null) return AppColors.outline;

    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.workCategory;
      case 'personal':
        return AppColors.personalCategory;
      case 'ideas':
        return AppColors.ideasCategory;
      case 'archive':
        return AppColors.archiveCategory;
      default:
        return AppColors.outline;
    }
  }

  /// Truncate text to specified length
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get first lines of text (for content preview)
  static String getContentPreview(String content, int maxLines) {
    final lines = content.split('\n');
    if (lines.length <= maxLines) return content;

    return lines.take(maxLines).join('\n');
  }

  /// Calculate reading time for content
  static String getReadingTime(String content) {
    const wordsPerMinute = 200;
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / wordsPerMinute).ceil();

    if (minutes < 1) return '< 1 min read';
    return '$minutes min read';
  }

  /// Debounce function calls
  static void debounce(
    Duration duration,
    VoidCallback callback, {
    String? tag,
  }) {
    _debounceTimers[tag ?? 'default']?.cancel();
    _debounceTimers[tag ?? 'default'] = Timer(duration, callback);
  }

  static final Map<String, Timer> _debounceTimers = {};
}
