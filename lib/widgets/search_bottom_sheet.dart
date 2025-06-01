import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'widgets.dart';

/// Search bottom sheet widget with debounced search functionality
class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  List<Note> _searchResults = [];
  bool _isSearching = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _setupSearchStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _setupSearchStream() {
    _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
      _performSearch(query);
    });
  }

  void _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final notesService = context.read<NotesService>();
      List<Note> results;

      if (query.isEmpty && _selectedCategory == null) {
        results = notesService.notes;
      } else {
        // Get all notes first
        var allNotes = notesService.notes;

        // Filter by category if selected
        if (_selectedCategory != null) {
          allNotes = allNotes
              .where((note) =>
                  note.category?.toLowerCase() ==
                  _selectedCategory!.toLowerCase())
              .toList();
        }

        // Apply text search if query is not empty
        if (query.isNotEmpty) {
          final lowercaseQuery = query.toLowerCase();
          results = allNotes.where((note) {
            final titleMatch =
                note.title.toLowerCase().contains(lowercaseQuery);
            final contentMatch =
                note.content.toLowerCase().contains(lowercaseQuery);
            final categoryMatch =
                note.category?.toLowerCase().contains(lowercaseQuery) ?? false;
            return titleMatch || contentMatch || categoryMatch;
          }).toList();
        } else {
          results = allNotes;
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        UIUtils.showErrorSnackBar(
          context,
          'Search failed: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesService>(
      builder: (context, notesService, child) {
        final categories = notesService.getCategories();

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusL),
              topRight: Radius.circular(AppSizes.radiusL),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Row(
                  children: [
                    Text(
                      AppStrings.searchButton,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: AppStrings.backButton,
                    ),
                  ],
                ),
              ),

              // Search input
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchByTitle,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _searchSubject.add('');
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: AppStrings.clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _searchSubject.add(value);
                  },
                ),
              ),

              // Category filter
              if (categories.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceM),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.filterByCategory,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Wrap(
                        spacing: AppSizes.spaceS,
                        children: [
                          // All categories chip
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                              _searchSubject.add(_searchController.text);
                            },
                          ),
                          // Category chips
                          ...categories.map(
                            (category) => FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                });
                                _searchSubject.add(_searchController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.spaceM),

              // Results
              Expanded(
                child: _buildSearchResults(context, notesService),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, NotesService notesService) {
    if (_isSearching) {
      return const LoadingWidget(message: AppStrings.searching);
    }

    // Show initial state if no search has been performed
    if (_searchController.text.isEmpty && _selectedCategory == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              'Start typing to search notes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Search by title, content, or category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    // Show empty results
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              AppStrings.noSearchResults,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Try different keywords or clear filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    // Show search results
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final note = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
          child: NoteCard(
            note: note,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                '/note-detail',
                arguments: note,
              );
            },
            onEdit: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                '/add-edit-note',
                arguments: note,
              );
            },
            onDelete: () async {
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
                    // Refresh search results
                    _searchSubject.add(_searchController.text);
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
            },
          ),
        );
      },
    );
  }
}
