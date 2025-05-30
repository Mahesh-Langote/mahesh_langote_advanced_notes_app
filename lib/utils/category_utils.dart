import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';

/// Information about a category including display properties
class CategoryInfo {
  final String displayName;
  final Color color;
  final IconData icon;

  const CategoryInfo({
    required this.displayName,
    required this.color,
    required this.icon,
  });
}

/// Utility class for category-related operations
/// Provides colors, icons, and helper methods for note categories
class CategoryUtils {
  CategoryUtils._(); // Private constructor to prevent instantiation

  /// Convert string category to NoteCategory enum
  static NoteCategory? stringToCategory(String? categoryString) {
    if (categoryString == null) return null;

    switch (categoryString.toLowerCase()) {
      case 'work':
        return NoteCategory.work;
      case 'personal':
        return NoteCategory.personal;
      case 'ideas':
        return NoteCategory.ideas;
      case 'archive':
        return NoteCategory.archive;
      default:
        return null;
    }
  }

  /// Get comprehensive category information from string
  static CategoryInfo? getCategoryInfoFromString(String? categoryString) {
    final category = stringToCategory(categoryString);
    return category != null ? getCategoryInfo(category) : null;
  }

  /// Get comprehensive category information
  static CategoryInfo getCategoryInfo(NoteCategory category) {
    switch (category) {
      case NoteCategory.work:
        return CategoryInfo(
          displayName: AppStrings.categoryWork,
          color: AppColors.primary,
          icon: Icons.work_outline,
        );
      case NoteCategory.personal:
        return CategoryInfo(
          displayName: AppStrings.categoryPersonal,
          color: AppColors.secondary,
          icon: Icons.person_outline,
        );
      case NoteCategory.ideas:
        return CategoryInfo(
          displayName: AppStrings.categoryIdeas,
          color: AppColors.tertiary,
          icon: Icons.lightbulb_outline,
        );
      case NoteCategory.archive:
        return CategoryInfo(
          displayName: AppStrings.categoryArchive,
          color: AppColors.onSurfaceVariant,
          icon: Icons.archive_outlined,
        );
    }
  }

  /// Get the color associated with a category
  static Color getCategoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.work:
        return AppColors.primary;
      case NoteCategory.personal:
        return AppColors.secondary;
      case NoteCategory.ideas:
        return AppColors.tertiary;
      case NoteCategory.archive:
        return AppColors.onSurfaceVariant;
    }
  }

  /// Get the icon associated with a category
  static IconData getCategoryIcon(NoteCategory category) {
    switch (category) {
      case NoteCategory.work:
        return Icons.work_outline;
      case NoteCategory.personal:
        return Icons.person_outline;
      case NoteCategory.ideas:
        return Icons.lightbulb_outline;
      case NoteCategory.archive:
        return Icons.archive_outlined;
    }
  }

  /// Get a lighter shade of the category color for backgrounds
  static Color getCategoryColorLight(NoteCategory category) {
    return getCategoryColor(category).withOpacity(0.1);
  }

  /// Get a chip widget for displaying category
  static Widget getCategoryChip(
    NoteCategory category, {
    bool showIcon = true,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingXS,
          ),
      decoration: BoxDecoration(
        color: getCategoryColorLight(category),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: getCategoryColor(category).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getCategoryIcon(category),
              size: fontSize != null ? fontSize + 2 : 14,
              color: getCategoryColor(category),
            ),
            const SizedBox(width: AppSizes.spaceXS),
          ],
          Text(
            category.displayName,
            style: TextStyle(
              color: getCategoryColor(category),
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get all categories with their counts (for filtering)
  static Map<NoteCategory, int> getCategoryCounts(List<Note> notes) {
    final counts = <NoteCategory, int>{};

    for (final category in NoteCategory.values) {
      counts[category] = 0;
    }

    for (final note in notes) {
      final category = NoteCategory.fromString(note.category);
      if (category != null) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Filter notes by category
  static List<Note> filterByCategory(List<Note> notes, NoteCategory? category) {
    if (category == null) return notes;

    return notes.where((note) {
      final noteCategory = NoteCategory.fromString(note.category);
      return noteCategory == category;
    }).toList();
  }

  /// Get the most used category from a list of notes
  static NoteCategory? getMostUsedCategory(List<Note> notes) {
    if (notes.isEmpty) return null;

    final counts = getCategoryCounts(notes);
    int maxCount = 0;
    NoteCategory? mostUsed;

    counts.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = category;
      }
    });

    return maxCount > 0 ? mostUsed : null;
  }

  /// Get categories sorted by usage (most used first)
  static List<NoteCategory> getCategoriesByUsage(List<Note> notes) {
    final counts = getCategoryCounts(notes);
    final categories = counts.keys.toList();

    categories.sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return categories;
  }
}
