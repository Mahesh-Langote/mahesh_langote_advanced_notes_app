/// App string constants for consistent text throughout the application
/// Used for all UI text, labels, messages, and error handling
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App metadata
  static const String appName = 'Advanced Notes';
  static const String appVersion = '1.0.0';

  // Navigation and routing
  static const String homeRoute = '/';
  static const String addNoteRoute = '/add-note';
  static const String editNoteRoute = '/edit-note';
  static const String noteDetailRoute = '/note-detail';

  // Home screen
  static const String homeTitle = 'My Notes';
  static const String homeSubtitle = 'Capture your thoughts';
  static const String searchHint = 'Search notes...';
  static const String noNotesTitle = 'No notes yet';
  static const String noNotesSubtitle =
      'Tap the + button to create your first note';
  static const String createFirstNote = 'Create your first note';

  // Add/Edit note screen
  static const String addNoteTitle = 'New Note';
  static const String editNoteTitle = 'Edit Note';
  static const String titleLabel = 'Title';
  static const String titleHint = 'Enter note title';
  static const String contentLabel = 'Content';
  static const String contentHint = 'Start writing your note...';
  static const String categoryLabel = 'Category';
  static const String categoryHint = 'Select category';
  static const String saveNote = 'Save Note';
  static const String updateNote = 'Update Note';
  static const String discardChanges = 'Discard Changes';

  // Note detail screen
  static const String noteDetailTitle = 'Note Details';
  static const String editNote = 'Edit';
  static const String deleteNote = 'Delete';
  static const String shareNote = 'Share';
  static const String createdAt = 'Created';
  static const String lastModified = 'Last modified';

  // Categories
  static const String categoryWork = 'Work';
  static const String categoryPersonal = 'Personal';
  static const String categoryIdeas = 'Ideas';
  static const String categoryArchive = 'Archive';
  static const String categoryAll = 'All';
  static const String categoryNone = 'Uncategorized';

  // Actions and buttons
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String done = 'Done';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String previous = 'Previous';

  // Dialogs and confirmations
  static const String deleteNoteTitle = 'Delete Note';
  static const String deleteNoteMessage =
      'Are you sure you want to delete this note? This action cannot be undone.';
  static const String discardChangesTitle = 'Discard Changes';
  static const String discardChangesMessage =
      'You have unsaved changes. Are you sure you want to discard them?';
  static const String conflictResolutionTitle = 'Note Conflict';
  static const String conflictResolutionMessage =
      'This note has been modified elsewhere. Choose how to resolve:';
  static const String keepLocal = 'Keep Local Version';
  static const String keepRemote = 'Keep Server Version';
  static const String mergeChanges = 'Merge Changes';

  // Validation messages
  static const String titleRequired = 'Title is required';
  static const String titleTooShort = 'Title must be at least 5 characters';
  static const String titleTooLong = 'Title must be less than 100 characters';
  static const String contentRequired = 'Content is required';
  static const String contentTooShort =
      'Content must be at least 10 characters';
  static const String categoryRequired = 'Please select a category';

  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorStorage = 'Storage error. Unable to save data.';
  static const String errorNotFound = 'Note not found.';
  static const String errorValidation =
      'Please check your input and try again.';
  static const String errorPermission = 'Permission denied.';
  static const String errorTimeout = 'Operation timed out. Please try again.';

  // Success messages
  static const String noteSaved = 'Note saved successfully';
  static const String noteUpdated = 'Note updated successfully';
  static const String noteDeleted = 'Note deleted successfully';
  static const String noteShared = 'Note shared successfully';

  // Loading states
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String deleting = 'Deleting...';
  static const String searching = 'Searching...';
  static const String loadingNotes = 'Loading notes...';

  // Search and filter
  static const String searchResults = 'Search Results';
  static const String noSearchResults = 'No notes found';
  static const String searchByTitle = 'Search by title';
  static const String searchByContent = 'Search by content';
  static const String searchByCategory = 'Search by category';
  static const String filterByCategory = 'Filter by category';
  static const String clearSearch = 'Clear search';
  static const String clearFilters = 'Clear filters';

  // Accessibility labels
  static const String addNoteButton = 'Add new note';
  static const String searchButton = 'Search notes';
  static const String menuButton = 'Open menu';
  static const String backButton = 'Go back';
  static const String moreOptionsButton = 'More options';
  static const String categoryChip = 'Category';
  static const String dateLabel = 'Date';

  // Date and time formatting
  static const String todayAt = 'Today at';
  static const String yesterdayAt = 'Yesterday at';
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy at HH:mm';

  // Empty states
  static const String emptyTrash = 'Trash is empty';
  static const String emptyCategory = 'No notes in this category';
  static const String emptySearch = 'No matching notes found';
  static const String emptyFavorites = 'No favorite notes';

  // Settings and preferences
  static const String settings = 'Settings';
  static const String preferences = 'Preferences';
  static const String theme = 'Theme';
  static const String language = 'Language';
  static const String about = 'About';
  static const String help = 'Help';
  static const String feedback = 'Feedback';

  // Tutorial and onboarding
  static const String welcomeTitle = 'Welcome to Advanced Notes';
  static const String welcomeSubtitle = 'Organize your thoughts efficiently';
  static const String getStarted = 'Get Started';
  static const String skipTutorial = 'Skip';
  static const String nextStep = 'Next';
  static const String previousStep = 'Previous';
  static const String finishTutorial = 'Finish';
}
