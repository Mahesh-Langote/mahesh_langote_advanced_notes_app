/// Custom exception classes for the notes application
/// Provides structured error handling throughout the application

/// Base exception class for notes service errors
class NotesServiceException implements Exception {
  final String message;
  final NotesServiceError errorType;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const NotesServiceException(
    this.message,
    this.errorType, [
    this.originalError,
    this.stackTrace,
  ]);

  @override
  String toString() {
    return 'NotesServiceException: $message (Type: $errorType)';
  }
}

/// Enumeration of possible service error types
enum NotesServiceError {
  /// Storage-related errors (Hive operations)
  storageFailure('Storage operation failed'),

  /// Resource not found errors
  notFound('Resource not found'),

  /// Validation errors for input data
  validationError('Validation failed'),

  /// Network-related errors (for future use)
  networkError('Network operation failed'),

  /// Permission-related errors
  permissionDenied('Permission denied'),

  /// Timeout errors
  timeout('Operation timed out'),

  /// Unknown or unexpected errors
  unknown('Unknown error occurred');

  const NotesServiceError(this.description);

  final String description;
}

/// Exception for form validation errors
class ValidationException implements Exception {
  final String field;
  final String message;
  final dynamic value;

  const ValidationException(this.field, this.message, [this.value]);

  @override
  String toString() {
    return 'ValidationException: $field - $message';
  }
}

/// Exception for data conflict situations
class DataConflictException implements Exception {
  final String message;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? remoteData;

  const DataConflictException(
    this.message, [
    this.localData,
    this.remoteData,
  ]);

  @override
  String toString() {
    return 'DataConflictException: $message';
  }
}
