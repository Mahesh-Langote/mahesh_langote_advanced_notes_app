import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'add_edit_note_screen.dart';

/// Home screen displaying all notes with SliverAppBar
/// Uses CustomScrollView as mandated by requirements
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _hasActiveFilters = false;
  // Filter state persistence
  NoteCategory? _currentFilterCategory;
  SortOption _currentSortOption = SortOption.dateNewest;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load notes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesService>().getAllNotes();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (_isScrolled != isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NotesService>(
        builder: (context, notesService, child) {
          _hasActiveFilters = notesService.hasActiveFilters;

          return StreamBuilder<List<Note>>(
            stream: _hasActiveFilters
                ? notesService.filteredNotesStream
                : notesService.notesStream,
            builder: (context, snapshot) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(context, notesService),
                  _buildContent(context, snapshot, notesService),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Build the dynamic SliverAppBar as per requirements
  Widget _buildSliverAppBar(BuildContext context, NotesService notesService) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getSliverAppBarHeight(context),
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: _isScrolled ? 4 : 0,

      // Dynamic background based on scroll
      backgroundColor: _isScrolled
          ? AppColors.surface.withOpacity(0.95)
          : Colors.transparent,

      // Gradient background when expanded
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppSizes.paddingM,
          bottom: AppSizes.paddingM,
        ),
        title: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 200),
          child: Text(
            AppStrings.homeTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.appBarGradient,
              stops: [0.0, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.surface.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ), // Action buttons that appear/disappear based on scroll
      actions: [
        if (!_isScrolled) ...[
          IconButton(
            onPressed: () => _showSearchBottomSheet(context),
            icon: const Icon(Icons.search),
            color: AppColors.onSurface,
            tooltip: AppStrings.searchButton,
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => _showFilterBottomSheet(context, notesService),
                icon: const Icon(Icons.filter_list),
                color:
                    _hasActiveFilters ? AppColors.primary : AppColors.onSurface,
                tooltip: 'Filter notes',
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (_hasActiveFilters)
            IconButton(
              onPressed: () {
                notesService.clearFilters();
                UIUtils.showSuccessSnackBar(context, 'Filters cleared');
              },
              icon: const Icon(Icons.clear),
              color: AppColors.onSurface,
              tooltip: 'Clear filters',
            ),
        ],
        if (_isScrolled) ...[
          IconButton(
            onPressed: () => _navigateToAddNote(context),
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            tooltip: AppStrings.addNoteButton,
          ),
        ],
        const SizedBox(width: AppSizes.paddingS),
      ],
    );
  }

  /// Build the main content area
  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<List<Note>> snapshot,
    NotesService notesService,
  ) {
    // Show loading state
    if (notesService.isLoading && !snapshot.hasData) {
      return const SliverFillRemaining(
        child: LoadingWidget(message: AppStrings.loadingNotes),
      );
    }

    // Show error state
    if (snapshot.hasError || notesService.lastError != null) {
      return SliverFillRemaining(
        child: CustomErrorWidget(
          message: notesService.lastError ?? 'Failed to load notes',
          onRetry: () => notesService.getAllNotes(),
        ),
      );
    }

    final notes = snapshot.data ?? []; // Show empty state
    if (notes.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(),
      );
    }

    // Show notes list
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
              child: NoteCard(
                note: note,
                onTap: () => _navigateToNoteDetail(context, note),
                onEdit: () => _navigateToEditNote(context, note),
                onDelete: () => _deleteNote(context, note, notesService),
              ),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddNote(context),
      tooltip: AppStrings.addNoteButton,
      child: const Icon(Icons.add),
    );
  }

  /// Navigation methods
  Future<void> _navigateToAddNote(BuildContext context) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => const AddEditNoteScreen(),
      ),
    );

    // Refresh notes list if a note was added
    if (result != null && mounted) {
      context.read<NotesService>().getAllNotes();
    }
  }

  Future<void> _navigateToEditNote(BuildContext context, Note note) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(noteToEdit: note),
      ),
    );

    // Refresh notes list if a note was updated
    if (result != null && mounted) {
      context.read<NotesService>().getAllNotes();
    }
  }

  void _navigateToNoteDetail(BuildContext context, Note note) {
    Navigator.of(context).pushNamed(
      '/note-detail',
      arguments: note,
    );
  }

  /// Show search bottom sheet
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchBottomSheet(),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context, NotesService notesService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCategory: _currentFilterCategory,
        initialSortOption: _currentSortOption,
        initialStartDate: _currentStartDate,
        initialEndDate: _currentEndDate,
        onApplyFilters:
            (filteredNotes, category, sortOption, startDate, endDate) {
          // Store current filter state
          setState(() {
            _currentFilterCategory = category;
            _currentSortOption = sortOption;
            _currentStartDate = startDate;
            _currentEndDate = endDate;
            _hasActiveFilters = _isFiltersActive();
          });
          notesService.applyFilters(filteredNotes);
        },
      ),
    );
  }

  /// Check if any filters are currently active
  bool _isFiltersActive() {
    return _currentFilterCategory != null ||
        _currentStartDate != null ||
        _currentEndDate != null ||
        _currentSortOption != SortOption.dateNewest;
  }

  /// Delete note with confirmation
  Future<void> _deleteNote(
    BuildContext context,
    Note note,
    NotesService notesService,
  ) async {
    final confirmed = await UIUtils.showConfirmationDialog(
      context,
      title: AppStrings.deleteNoteTitle,
      message: AppStrings.deleteNoteMessage,
      confirmText: AppStrings.delete,
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      try {
        await notesService.deleteNote(note.id);
        if (mounted) {
          UIUtils.showSuccessSnackBar(
            context,
            AppStrings.noteDeleted,
          );
        }
      } catch (e) {
        if (mounted) {
          UIUtils.showErrorSnackBar(
            context,
            'Failed to delete note: ${e.toString()}',
          );
        }
      }
    }
  }
}
