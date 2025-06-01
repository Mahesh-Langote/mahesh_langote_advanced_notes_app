import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

import '../models/models.dart';
import '../core/exceptions.dart';

/// Service class for managing notes data operations
/// Handles all CRUD operations and provides reactive streams
/// Registered with GetIt for dependency injection
class NotesService extends ChangeNotifier {
  static const String _notesBoxName = 'notes';
  late Box<Note> _notesBox;
  final Uuid _uuid = const Uuid();

  // Reactive streams for real-time updates
  final BehaviorSubject<List<Note>> _notesController =
      BehaviorSubject<List<Note>>();
  final BehaviorSubject<bool> _loadingController =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorController = BehaviorSubject<String?>();

  // Filtered notes stream for custom filtering/sorting
  final BehaviorSubject<List<Note>> _filteredNotesController =
      BehaviorSubject<List<Note>>();

  // Public streams
  Stream<List<Note>> get notesStream => _notesController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<List<Note>> get filteredNotesStream => _filteredNotesController.stream;

  // Current state getters
  List<Note> get notes => _notesController.value;
  bool get isLoading => _loadingController.value;
  String? get lastError => _errorController.value;

  /// Initialize the service and open Hive box
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Open Hive box
      _notesBox = await Hive.openBox<Note>(_notesBoxName);

      // Load initial data
      await _loadNotes();
    } catch (e, stackTrace) {
      _handleError(
        NotesServiceException(
          'Failed to initialize notes service',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new note
  Future<Note> createNote({
    required String title,
    required String content,
    String? category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate input
      _validateNoteInput(title, content);

      // Create new note
      final now = DateTime.now();
      final note = Note(
        id: _uuid.v4(),
        title: title.trim(),
        content: content.trim(),
        category: category?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      // Save to Hive
      await _notesBox.put(note.id, note);

      // Update stream
      await _loadNotes();

      return note;
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;

      _handleError(
        NotesServiceException(
          'Failed to create note',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get all notes
  Future<List<Note>> getAllNotes() async {
    try {
      _setLoading(true);
      _clearError();

      await _loadNotes();
      return notes;
    } catch (e, stackTrace) {
      _handleError(
        NotesServiceException(
          'Failed to load notes',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      _clearError();

      final note = _notesBox.get(id);
      return note;
    } catch (e, stackTrace) {
      _handleError(
        NotesServiceException(
          'Failed to get note by ID',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
      return null;
    }
  }

  /// Update an existing note
  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
    String? category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate input
      _validateNoteInput(title, content);

      // Get existing note
      final existingNote = _notesBox.get(id);
      if (existingNote == null) {
        throw NotesServiceException(
          'Note not found',
          NotesServiceError.notFound,
        );
      }

      // Create updated note
      final updatedNote = existingNote.copyWith(
        title: title.trim(),
        content: content.trim(),
        category: category?.trim(),
        updatedAt: DateTime.now(),
      );

      // Save to Hive
      await _notesBox.put(id, updatedNote);

      // Update stream
      await _loadNotes();

      return updatedNote;
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotesServiceException) rethrow;

      _handleError(
        NotesServiceException(
          'Failed to update note',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if note exists
      if (!_notesBox.containsKey(id)) {
        throw NotesServiceException(
          'Note not found',
          NotesServiceError.notFound,
        );
      }

      // Delete from Hive
      await _notesBox.delete(id);

      // Update stream
      await _loadNotes();
    } catch (e, stackTrace) {
      if (e is NotesServiceException) rethrow;

      _handleError(
        NotesServiceException(
          'Failed to delete note',
          NotesServiceError.storageFailure,
          e,
          stackTrace,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Search notes with debouncing
  Stream<List<Note>> searchNotes(String query) {
    return Stream.value(query)
        .debounceTime(const Duration(milliseconds: 300))
        .map((searchQuery) => _performSearch(searchQuery));
  }

  /// Filter notes by category
  List<Note> filterByCategory(String? category) {
    if (category == null || category.isEmpty) {
      return notes;
    }

    return notes
        .where((note) => note.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get unique categories from all notes
  List<String> getCategories() {
    final categories = notes
        .where((note) => note.category != null)
        .map((note) => note.category!)
        .toSet()
        .toList();

    categories.sort();
    return categories;
  }

  /// Apply custom filters to notes and update filtered stream
  void applyFilters(List<Note> filteredNotes) {
    _filteredNotesController.add(filteredNotes);
    notifyListeners();
  }

  /// Clear filters and show all notes
  void clearFilters() {
    _filteredNotesController.add(notes);
    notifyListeners();
  }

  /// Check if filters are currently applied
  bool get hasActiveFilters {
    if (!_filteredNotesController.hasValue) return false;
    return _filteredNotesController.value.length != notes.length;
  }

  /// Get current filtered notes
  List<Note> get filteredNotes {
    if (_filteredNotesController.hasValue) {
      return _filteredNotesController.value;
    }
    return notes;
  }

  /// Private helper methods

  Future<void> _loadNotes() async {
    try {
      final notesList = _notesBox.values.toList();
      // Sort by updatedAt descending (most recent first)
      notesList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _notesController.add(notesList);
      _filteredNotesController.add(notesList); // Update filtered notes stream
    } catch (e) {
      _notesController.addError(e);
      _filteredNotesController.addError(e);
    }
  }

  List<Note> _performSearch(String query) {
    if (query.isEmpty) return notes;

    final lowercaseQuery = query.toLowerCase();

    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowercaseQuery);
      final contentMatch = note.content.toLowerCase().contains(lowercaseQuery);
      final categoryMatch =
          note.category?.toLowerCase().contains(lowercaseQuery) ?? false;

      return titleMatch || contentMatch || categoryMatch;
    }).toList();
  }

  void _validateNoteInput(String title, String content) {
    if (title.trim().isEmpty) {
      throw ValidationException('title', 'Title is required');
    }

    if (title.trim().length < 5) {
      throw ValidationException('title', 'Title must be at least 5 characters');
    }

    if (title.trim().length > 100) {
      throw ValidationException(
          'title', 'Title must be less than 100 characters');
    }

    if (content.trim().isEmpty) {
      throw ValidationException('content', 'Content is required');
    }

    if (content.trim().length < 10) {
      throw ValidationException(
          'content', 'Content must be at least 10 characters');
    }
  }

  void _setLoading(bool loading) {
    _loadingController.add(loading);
  }

  void _clearError() {
    _errorController.add(null);
  }

  void _handleError(NotesServiceException error) {
    _errorController.add(error.message);
    debugPrint('NotesService Error: $error');
  }

  /// Dispose method to clean up resources
  @override
  void dispose() {
    _notesController.close();
    _loadingController.close();
    _errorController.close();
    _filteredNotesController.close();
    super.dispose();
  }
}
