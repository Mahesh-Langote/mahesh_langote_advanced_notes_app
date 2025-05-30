import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Widget displayed when no notes are available
/// Shows an illustration and encourages user to create their first note
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppSizes.spaceL),

            // Title
            Text(
              AppStrings.emptyNotesTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceM),

            // Description
            Text(
              AppStrings.emptyNotesMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceXL), // Create note button
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/add-note');
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.createFirstNote),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
