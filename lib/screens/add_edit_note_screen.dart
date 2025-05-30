import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

/// Screen for adding new notes or editing existing ones
/// Uses ReactiveForm as mandated by requirements
class AddEditNoteScreen extends StatefulWidget {
  final Note? noteToEdit;
  final bool isEditing;

  const AddEditNoteScreen({
    super.key,
    this.noteToEdit,
  }) : isEditing = noteToEdit != null;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late final FormGroup form;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    form = FormGroup({
      'title': FormControl<String>(
        value: widget.noteToEdit?.title ?? '',
        validators: [
          Validators.required,
          Validators.minLength(AppConstants.minTitleLength),
          Validators.maxLength(AppConstants.maxTitleLength),
        ],
      ),
      'content': FormControl<String>(
        value: widget.noteToEdit?.content ?? '',
        validators: [
          Validators.required,
          Validators.minLength(AppConstants.minContentLength),
        ],
      ),
      'category': FormControl<NoteCategory>(
        value: widget.noteToEdit?.category != null
            ? NoteCategory.fromString(widget.noteToEdit!.category!)
            : null,
      ),
    });

    // Listen for form changes to track unsaved changes
    form.valueChanges.listen((_) {
      if (!_hasUnsavedChanges) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: ReactiveForm(
          formGroup: form,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              _buildFormContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 120,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 4,
      leading: IconButton(
        onPressed: () => _handleBackPress(context),
        icon: const Icon(Icons.arrow_back),
        color: AppColors.onSurface,
      ),
      title: Text(
        widget.isEditing ? AppStrings.editNoteTitle : AppStrings.addNoteTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        if (_hasUnsavedChanges)
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return IconButton(
                onPressed: form.valid ? () => _saveNote(context) : null,
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.check),
                color:
                    form.valid ? AppColors.primary : AppColors.onSurfaceVariant,
                tooltip: widget.isEditing
                    ? AppStrings.updateNote
                    : AppStrings.saveNote,
              );
            },
          ),
        const SizedBox(width: AppSizes.paddingS),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.appBarGradient,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Title field
          _buildTitleField(context),

          const SizedBox(height: AppSizes.spaceL),

          // Category field
          _buildCategoryField(context),

          const SizedBox(height: AppSizes.spaceL),

          // Content field
          _buildContentField(context),

          const SizedBox(height: AppSizes.spaceXL),

          // Action buttons
          _buildActionButtons(context),

          // Bottom padding for keyboard
          const SizedBox(height: AppSizes.spaceXXL),
        ]),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.titleLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        ReactiveTextField<String>(
          formControlName: 'title',
          decoration: InputDecoration(
            hintText: AppStrings.titleHint,
            filled: true,
            fillColor: AppColors.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textCapitalization: TextCapitalization.sentences,
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.titleRequired,
            ValidationMessage.minLength: (_) => AppStrings.titleTooShort,
            ValidationMessage.maxLength: (_) => AppStrings.titleTooLong,
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.categoryLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        ReactiveDropdownField<NoteCategory>(
          formControlName: 'category',
          decoration: InputDecoration(
            hintText: AppStrings.categoryHint,
            filled: true,
            fillColor: AppColors.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
          ),
          items: NoteCategory.values.map((category) {
            return DropdownMenuItem<NoteCategory>(
              value: category,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: CategoryUtils.getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.contentLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        ReactiveTextField<String>(
          formControlName: 'content',
          maxLines: 15,
          minLines: 8,
          decoration: InputDecoration(
            hintText: AppStrings.contentHint,
            filled: true,
            fillColor: AppColors.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            alignLabelWithHint: true,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textCapitalization: TextCapitalization.sentences,
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.contentRequired,
            ValidationMessage.minLength: (_) => AppStrings.contentTooShort,
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleBackPress(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                  side: BorderSide(color: AppColors.outline),
                ),
                child: const Text(AppStrings.cancel),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: FilledButton(
                onPressed:
                    form.valid && !_isSaving ? () => _saveNote(context) : null,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing
                        ? AppStrings.updateNote
                        : AppStrings.saveNote),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    return await _showDiscardDialog() ?? false;
  }

  Future<void> _handleBackPress(BuildContext context) async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await _showDiscardDialog();
    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _showDiscardDialog() async {
    return UIUtils.showConfirmationDialog(
      context,
      title: AppStrings.discardChangesTitle,
      message: AppStrings.discardChangesMessage,
      confirmText: AppStrings.discard,
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.error,
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    if (form.invalid || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final notesService = context.read<NotesService>();
      final formValue = form.value;
      if (widget.isEditing) {
        await notesService.updateNote(
          id: widget.noteToEdit!.id,
          title: formValue['title'] as String,
          content: formValue['content'] as String,
          category: (formValue['category'] as NoteCategory?)?.displayName,
        );
      } else {
        await notesService.createNote(
          title: formValue['title'] as String,
          content: formValue['content'] as String,
          category: (formValue['category'] as NoteCategory?)?.displayName,
        );
      }

      if (mounted) {
        UIUtils.showSuccessSnackBar(
          context,
          widget.isEditing ? AppStrings.noteUpdated : AppStrings.noteSaved,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorSnackBar(
          context,
          'Failed to save note: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
