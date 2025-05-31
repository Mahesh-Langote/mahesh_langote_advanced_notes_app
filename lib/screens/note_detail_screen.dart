import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../utils/date_utils.dart' as AppDateUtils;

/// Screen to display a note in detail with options to edit and delete
class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar.large(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surfaceTint,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        _buildEditButton(context),
        _buildDeleteButton(context),
        const SizedBox(width: AppSizes.spaceS),
      ],
      title: Text(
        AppStrings.noteDetails,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      pinned: true,
      expandedHeight: 200.0,
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit_outlined),
      tooltip: AppStrings.editNote,
      onPressed: () => _editNote(context),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: AppStrings.deleteNote,
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildNoteHeader(context),
          const SizedBox(height: AppSizes.spaceL),
          _buildNoteContent(context),
          const SizedBox(height: AppSizes.spaceXL),
          _buildNoteMetadata(context),
        ]),
      ),
    );
  }

  Widget _buildNoteHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        if (note.category != null) _buildCategoryChip(context),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final categoryInfo = CategoryUtils.getCategoryInfoFromString(note.category);

    if (categoryInfo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: categoryInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: categoryInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryInfo.icon,
            size: AppSizes.iconS,
            color: categoryInfo.color,
          ),
          const SizedBox(width: AppSizes.spaceS),
          Text(
            categoryInfo.displayName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: categoryInfo.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        note.content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface,
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildNoteMetadata(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.noteMetadata,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildMetadataRow(
            context,
            Icons.access_time,
            AppStrings.createdAt,
            AppDateUtils.DateUtils.formatDateTime(note.createdAt),
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildMetadataRow(
            context,
            Icons.update,
            AppStrings.updatedAt,
            AppDateUtils.DateUtils.formatDateTime(note.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: AppSizes.spaceS),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _editNote(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/add-edit-note',
      arguments: note,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            AppStrings.deleteNote,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            AppStrings.deleteNoteConfirmation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(
                AppStrings.delete,
                style: TextStyle(color: AppColors.onError),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(BuildContext context) async {
    try {
      final notesService = Provider.of<NotesService>(context, listen: false);
      await notesService.deleteNote(note.id);

      if (context.mounted) {
        Navigator.of(context).pop(); // Go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.noteDeleted),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.deleteNoteFailed}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
