import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../utils/date_utils.dart' as AppDateUtils;

/// Widget for displaying a note in a card format
/// Shows title, content preview, category, and timestamps
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSizes.spaceS),
              _buildTitle(context),
              const SizedBox(height: AppSizes.spaceS),
              _buildContent(context),
              const SizedBox(height: AppSizes.spaceM),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build card header with category and actions
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (note.category != null)
          _buildCategoryChip(context)
        else
          const SizedBox.shrink(),
        if (showActions) _buildActions(context),
      ],
    );
  }

  /// Build category chip
  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: UIUtils.getCategoryColor(note.category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: UIUtils.getCategoryColor(note.category).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        note.category!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: UIUtils.getCategoryColor(note.category),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          iconSize: AppSizes.iconS,
          color: AppColors.primary,
          tooltip: AppStrings.edit,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          iconSize: AppSizes.iconS,
          color: AppColors.error,
          tooltip: AppStrings.delete,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  /// Build note title
  Widget _buildTitle(BuildContext context) {
    return Text(
      note.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build note content preview
  Widget _buildContent(BuildContext context) {
    final contentPreview = UIUtils.getContentPreview(note.content, 3);

    return Text(
      contentPreview,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build footer with timestamps and reading time
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimestamps(context),
        _buildReadingTime(context),
      ],
    );
  }

  /// Build timestamps
  Widget _buildTimestamps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: AppSizes.iconXS,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${AppStrings.createdAt}: ${AppDateUtils.DateUtils.formatNoteDate(note.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
        if (note.updatedAt != note.createdAt) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.edit,
                size: AppSizes.iconXS,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppStrings.lastModified}: ${AppDateUtils.DateUtils.formatNoteDate(note.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build reading time indicator
  Widget _buildReadingTime(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryOpacity08,
        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
      ),
      child: Text(
        UIUtils.getReadingTime(note.content),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
