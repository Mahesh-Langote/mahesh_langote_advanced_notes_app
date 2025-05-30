import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../utils/date_utils.dart' as custom_date_utils;

/// Filter options for notes
enum SortOption {
  dateNewest('Newest First', Icons.keyboard_arrow_down),
  dateOldest('Oldest First', Icons.keyboard_arrow_up),
  titleAZ('Title A-Z', Icons.sort_by_alpha),
  titleZA('Title Z-A', Icons.sort_by_alpha),
  categoryGrouped('Group by Category', Icons.category);

  const SortOption(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Filter and sorting bottom sheet widget
class FilterBottomSheet extends StatefulWidget {
  final Function(List<Note>, NoteCategory?, SortOption, DateTime?, DateTime?)
      onApplyFilters;
  final NoteCategory? initialCategory;
  final SortOption initialSortOption;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const FilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    this.initialCategory,
    this.initialSortOption = SortOption.dateNewest,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late NoteCategory? _selectedCategory;
  late SortOption _selectedSortOption;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Initialize with passed values to maintain persistence
    _selectedCategory = widget.initialCategory;
    _selectedSortOption = widget.initialSortOption;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesService>(
      builder: (context, notesService, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusL),
              topRight: Radius.circular(AppSizes.radiusL),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSortingSection(),
                      const SizedBox(height: AppSizes.spaceL),
                      _buildCategoryFilterSection(notesService),
                      const SizedBox(height: AppSizes.spaceL),
                      _buildDateFilterSection(),
                      const SizedBox(height: AppSizes.spaceXL),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(context, notesService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSizes.spaceS),
          Text(
            'Filter & Sort Notes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildSortingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        ...SortOption.values.map(
          (option) => _buildSortOptionTile(option),
        ),
      ],
    );
  }

  Widget _buildSortOptionTile(SortOption option) {
    final isSelected = _selectedSortOption == option;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS,
        ),
        leading: Icon(
          option.icon,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        title: Text(
          option.displayName,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppColors.primary,
              )
            : null,
        onTap: () {
          setState(() {
            _selectedSortOption = option;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilterSection(NotesService notesService) {
    final categoryCounts = CategoryUtils.getCategoryCounts(notesService.notes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        // All categories option
        _buildCategoryTile(
          null,
          'All Categories',
          notesService.notes.length,
          Icons.all_inclusive,
          AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: AppSizes.spaceS),
        // Individual categories
        ...categoryCounts.entries.map(
          (entry) => _buildCategoryTile(
            entry.key,
            entry.key.displayName,
            entry.value,
            CategoryUtils.getCategoryIcon(entry.key),
            CategoryUtils.getCategoryColor(entry.key),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(
    NoteCategory? category,
    String displayName,
    int count,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isSelected ? color : AppColors.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS,
        ),
        leading: Icon(
          icon,
          color: isSelected ? color : AppColors.onSurfaceVariant,
        ),
        title: Text(
          displayName,
          style: TextStyle(
            color: isSelected ? color : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? color : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSizes.spaceS),
              Icon(
                Icons.check_circle,
                color: color,
              ),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            _selectedCategory = _selectedCategory == category ? null : category;
          });
        },
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Date Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                'Start Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: _buildDateSelector(
                'End Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null) ...[
          const SizedBox(height: AppSizes.spaceM),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Date Filter'),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  selectedDate != null
                      ? custom_date_utils.DateUtils.formatDate(selectedDate)
                      : 'Select date',
                  style: TextStyle(
                    color: selectedDate != null
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, NotesService notesService) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedSortOption = SortOption.dateNewest;
                  _startDate = null;
                  _endDate = null;
                });
              },
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _applyFilters(context, notesService),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters(BuildContext context, NotesService notesService) {
    var filteredNotes = notesService.notes;

    // Apply category filter
    if (_selectedCategory != null) {
      filteredNotes =
          CategoryUtils.filterByCategory(filteredNotes, _selectedCategory);
    }

    // Apply date range filter
    if (_startDate != null || _endDate != null) {
      filteredNotes = filteredNotes.where((note) {
        final noteDate = note.createdAt;

        if (_startDate != null && noteDate.isBefore(_startDate!)) {
          return false;
        }

        if (_endDate != null &&
            noteDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply sorting
    switch (_selectedSortOption) {
      case SortOption.dateNewest:
        filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.dateOldest:
        filteredNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case SortOption.titleAZ:
        filteredNotes.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleZA:
        filteredNotes.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.categoryGrouped:
        filteredNotes.sort((a, b) {
          final categoryA = a.category ?? '';
          final categoryB = b.category ?? '';
          final categoryComparison = categoryA.compareTo(categoryB);

          if (categoryComparison != 0) {
            return categoryComparison;
          }

          // If same category, sort by date (newest first)
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    } // Apply the filtered results
    widget.onApplyFilters(
      filteredNotes,
      _selectedCategory,
      _selectedSortOption,
      _startDate,
      _endDate,
    );

    // Show success message
    UIUtils.showSuccessSnackBar(
      context,
      'Filters applied: ${filteredNotes.length} notes found',
    );

    // Close the bottom sheet
    Navigator.of(context).pop();
  }
}
