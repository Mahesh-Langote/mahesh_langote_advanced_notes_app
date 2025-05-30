import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'note.freezed.dart';
part 'note.g.dart';

/// Note model representing a single note in the application
/// Uses Freezed for immutability and Hive for local storage
@freezed
@HiveType(typeId: 0)
class Note with _$Note {
  const factory Note({
    @HiveField(0) required String id, // Use UUID for unique IDs

    @HiveField(1) required String title,
    @HiveField(2) required String content,
    @HiveField(3) String? category,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}

/// Note categories enum for better type safety
@HiveType(typeId: 1)
enum NoteCategory {
  @HiveField(0)
  work('Work'),

  @HiveField(1)
  personal('Personal'),

  @HiveField(2)
  ideas('Ideas'),

  @HiveField(3)
  archive('Archive');

  const NoteCategory(this.displayName);

  final String displayName;

  /// Get category by name (case-insensitive)
  static NoteCategory? fromString(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return null;

    try {
      return NoteCategory.values.firstWhere(
        (category) =>
            category.displayName.toLowerCase() == categoryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all category display names
  static List<String> get allDisplayNames =>
      NoteCategory.values.map((category) => category.displayName).toList();
}
