/// Application-wide constants for various configurations
/// Contains validation rules, limits, and other app-specific values
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Form validation constants
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int minContentLength = 10;
  static const int maxContentLength = 10000;

  // Note display constants
  static const int maxPreviewLines = 3;
  static const int wordsPerMinute = 200; // Average reading speed
  static const int maxSearchResults = 50;
  static const int recentNotesLimit = 10;

  // Performance constants
  static const int searchDebounceMs = 500;
  static const int autosaveIntervalMs = 30000; // 30 seconds
  static const int maxCachedNotes = 100;

  // Animation constants
  static const int defaultAnimationMs = 300;
  static const int fastAnimationMs = 150;
  static const int slowAnimationMs = 600;

  // Storage constants
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';
  static const String userPrefsBoxName = 'user_prefs_box';

  // Categories constants
  static const int maxCategories = 10;
  static const int maxCategoryNameLength = 30;

  // Export/Import constants
  static const List<String> supportedExportFormats = ['json', 'txt', 'md'];
  static const int maxExportNotes = 1000;

  // Search constants
  static const int minSearchQueryLength = 2;
  static const int maxSearchHistory = 20;

  // Backup constants
  static const int maxBackupFiles = 5;
  static const int backupIntervalDays = 7;

  // UI constants
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;

  // Network constants (for future use)
  static const int requestTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;
}
