import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Widget displayed while loading data
/// Shows a circular progress indicator with loading text
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3.0,
              color: theme.colorScheme.primary,
            ),
            if (message != null) ...[
              SizedBox(height: AppSizes.spaceL),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sliver version of loading widget for use in CustomScrollView
class SliverLoadingWidget extends StatelessWidget {
  final String? message;

  const SliverLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: LoadingWidget(message: message),
    );
  }
}
