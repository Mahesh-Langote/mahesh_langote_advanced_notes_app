# Requirements Document: Advanced Notes Application

## Project Overview
Develop a feature-rich note-taking application demonstrating mastery of contemporary Flutter libraries, sophisticated form handling with `reactive_forms`, complex Sliver-based UI architecture, local data persistence using `Hive`

## Critical Technical Constraints

## Everything in this project use from the creating utils, custom widgets, and services.
## use constants for all the strings, colors, and other values.

### ❌ STRICTLY PROHIBITED
- `ListView` - **BANNED**
- `Column` (for primary scrollable page content) - **BANNED**
- `SingleChildScrollView` - **BANNED**
- `Row` (for primary scrollable page content) - **BANNED**
- Standard `Form` widget - **BANNED**
- Standard `TextFormField` - **BANNED**
- Any direct `Hive` operations in UI layer - **BANNED**

### ✅ MANDATORY REQUIREMENTS
- **UI Scrolling**: Exclusively `CustomScrollView` with various `Sliver` widgets
- **Forms**: Only `ReactiveForm` and `Reactive*` counterparts from `reactive_forms` package
- **Data Layer**: All CRUD operations through dedicated service layer
- **State Management**: Provider pattern throughout
- **Models**: Immutable models using `freezed` and `json_serializable`

## Required Dependencies

### Core Packages (Mandatory)
```yaml
dependencies:
  # Routing
  auto_route: ^latest
  
  # State Management
  provider: ^latest
  
  # Dependency Injection
  get_it: ^latest
  
  # Form Handling
  reactive_forms: ^latest
  reactive_forms_builder: ^latest
  
  # Data Models
  freezed_annotation: ^latest
  json_annotation: ^latest
  
  # Local Storage
  hive: ^latest
  hive_flutter: ^latest
  
  # Utilities
  uuid: ^latest
  rxdart: ^latest

dev_dependencies:
  # Code Generation
  build_runner: ^latest
  auto_route_generator: ^latest
  freezed: ^latest
  json_serializable: ^latest
  hive_generator: ^latest
```

### Permitted Sliver Widgets
- `SliverList`
- `SliverGrid`
- `SliverToBoxAdapter`
- `SliverAppBar`
- `SliverPersistentHeader`
- `SliverFillRemaining`
- `SliverReorderableList`
- Any other `Sliver*` widgets

## Data Models

### Note Model (Freezed + JSON Serializable)
```dart
@freezed
class Note with _$Note {
  const factory Note({
    required String id, // Use UUID for unique IDs
    required String title,
    required String content,
    String? category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
```

## Architecture Requirements

### Service Layer (Mandatory)
```dart
class NotesService {
  // All CRUD operations
  // Hive box management
  // Error handling
  // Registered with GetIt
}
```

### Dependency Injection Setup
- Register `NotesService` with `GetIt`
- UI components access services through `GetIt`, not directly

### State Management Pattern
- Use `Provider` for state management
- `ChangeNotifierProvider` for reactive state
- `Consumer` or `context.watch()` for UI updates
- `context.read()` for one-off operations

## Screen Requirements

### 1. Home Screen - Dynamic & Informative

#### Root Structure (Non-Negotiable)
```dart
CustomScrollView(
  slivers: [
    // Required Sliver widgets only
  ],
)
```

#### SliverAppBar Requirements
- **Expandable/Collapsible behavior**
- **Dynamic title display**
- **Background color changes based on scroll offset**
- **Action buttons** (e.g., "New Note") that appear/disappear on scroll
- **No standard AppBar allowed**

#### SliverList for Notes Display
Each note item MUST display:
- **Title** (prominently displayed)
- **Content snippet** (first 2 lines, truncated)
- **Creation date** (formatted)
- **Last modified date** (formatted)
- **Category** (if assigned, with visual distinction)

#### Empty State Implementation
- Use `SliverFillRemaining` OR `SliverToBoxAdapter`
- Display when no notes exist
- Guide user to create first note
- Must be within the `CustomScrollView` structure

### 2. Add/Edit Note Screen - Robust Form Handling

#### Form Implementation (Mandatory)
```dart
ReactiveForm( // OR ReactiveFormBuilder
  formGroup: formGroup,
  child: CustomScrollView( // Even forms must use CustomScrollView
    slivers: [
      // Form fields in Sliver widgets
    ],
  ),
)
```

#### Required Form Fields

##### Title Field
```dart
ReactiveTextField<String>(
  formControlName: 'title',
  // Validation: required, min 5 chars, max 100 chars
)
```

##### Content Field
```dart
ReactiveTextField<String>(
  formControlName: 'content',
  // Validation: required, min 10 chars, multi-line
  maxLines: null,
)
```

##### Category Field
```dart
ReactiveDropdownField<String>(
  formControlName: 'category',
  // Options: "Work", "Personal", "Ideas", "Archive"
  // Allow dynamic creation of new categories
)
```

#### Validation Requirements
- **Real-time validation** for all fields
- **Clear error messages** displayed immediately
- **Save button disabled** until form is completely valid
- **Pre-fill form** when editing existing note

#### Data Conflict Handling
- Handle potential background updates during editing
- Implement version-based conflict resolution OR merge strategy
- Show user-friendly conflict resolution UI

### 3. Note Detail Screen - Structured Display

#### Layout Structure
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(/* title, actions */),
    SliverToBoxAdapter(/* title display */),
    SliverToBoxAdapter(/* category display */),
    SliverToBoxAdapter(/* content display */),
    SliverToBoxAdapter(/* timestamps */),
    SliverToBoxAdapter(/* action buttons */),
  ],
)
```

#### Required Display Elements
- **Full note title** (prominently displayed)
- **Category** (with visual styling)
- **Complete content** (properly formatted)
- **Creation timestamp** (`createdAt`)
- **Last update timestamp** (`updatedAt`)
- **Edit button** (navigates to edit screen)
- **Delete button** (with confirmation dialog)

#### Action Requirements
- **Edit**: Navigate to Add/Edit screen with pre-filled data
- **Delete**: Show confirmation dialog before deletion
- **Navigation**: Proper back navigation handling

## Data Persistence Requirements

### Hive Integration (Mandatory)
```dart
// main.dart initialization
await Hive.initFlutter();
Hive.registerAdapter(NoteAdapter()); // Generated by hive_generator
await Hive.openBox<Note>('notes');
```

### Service Layer Architecture
```dart
class NotesService extends ChangeNotifier {
  late Box<Note> _notesBox;
  
  // CRUD Operations
  Future<void> createNote(Note note) async { }
  Future<List<Note>> getAllNotes() async { }
  Future<Note?> getNoteById(String id) async { }
  Future<void> updateNote(Note note) async { }
  Future<void> deleteNote(String id) async { }
  
  // Error handling for all operations
  // Loading state management
}
```

### Data Flow Rules
1. **UI** → **Service Layer** → **Hive**
2. **No direct Hive access** from UI components
3. **All operations asynchronous** with proper loading states
4. **Error handling** at service layer with user-friendly messages

## Advanced Features (Bonus Points)

### 1. Advanced Search & Filtering with Debouncing

#### Implementation Requirements
```dart
// In SliverAppBar or dedicated search section
ReactiveTextField<String>(
  formControlName: 'search',
  // Use rxdart's debounceTime operator
)

// Service method
Stream<List<Note>> searchNotes(String query) {
  return searchStream
    .debounceTime(Duration(milliseconds: 300))
    .map((query) => _performSearch(query));
}
```

#### Search Capabilities
- **Search by title** (case-insensitive)
- **Search by content** (partial matching)
- **Search by category** (exact and partial)
- **Combined filters** (text + category simultaneously)
- **Debounced input** (300ms delay minimum)

### 2. Basic Rich Text Editing

#### Integration Options
- Investigate `flutter_quill` with `reactive_forms`
- OR `zefyr_quill` integration
- OR custom bold/italic/underline controls

#### Requirements
- Replace standard `ReactiveTextField` for content
- Manage complex data format (not plain text)
- Maintain form validation compatibility
- Serialize rich text format for Hive storage

### 3. Optimistic UI Updates & Error Handling

#### Implementation Strategy
- **Immediate UI updates** for user actions
- **Background service operations** for persistence
- **Rollback mechanism** for failed operations
- **User notification** for operation status

#### Covered Operations
- Note creation (show immediately, persist in background)
- Note deletion (remove from UI, confirm in background)
- Quick category changes (update UI, sync with storage)
- Bulk operations (mark multiple, process individually)

## UI/UX Requirements

### Visual Design Standards
- **Material Design 3** compliance
- **Consistent spacing** and typography
- **Loading indicators** for async operations
- **Error states** with retry mechanisms
- **Empty states** with clear call-to-actions

### Performance Requirements
- **Smooth scrolling** in all CustomScrollView implementations
- **Efficient list rendering** for large note collections
- **Memory management** (proper dispose of FormGroups)
- **Responsive UI** during background operations

## Error Handling Requirements

### Service Layer Error Handling
```dart
class NotesServiceException implements Exception {
  final String message;
  final NotesServiceError errorType;
  NotesServiceException(this.message, this.errorType);
}

enum NotesServiceError {
  storageFailure,
  notFound,
  validationError,
  networkError, // for future use
}
```

### UI Error Display
- **Toast messages** for minor errors
- **Dialog boxes** for critical errors
- **Inline validation** messages for forms
- **Retry mechanisms** for recoverable errors

## Testing Strategy (Recommended)

### Unit Tests
- Service layer CRUD operations
- Model serialization/deserialization
- Form validation logic
- Search and filtering functions

### Widget Tests
- Form field validation
- Navigation flows
- Error state displays
- Empty state handling

### Integration Tests
- Complete note creation flow
- Search functionality
- Data persistence verification

## Git Commit Requirements

### Minimum Commit Count
- **At least 15 commits** with logical progression
- Each commit represents a complete, small feature or fix

### Commit Message Format (Conventional Commits)
```
type(scope): description

Examples:
feat(models): implement Note model with freezed
feat(services): create NotesService with Hive integration
feat(home): implement CustomScrollView with SliverAppBar
feat(forms): create reactive form for note creation
fix(validation): resolve form validation edge cases
refactor(ui): extract reusable note tile widget
style: apply consistent formatting and linting
docs: update README with setup instructions
```

### Prohibited Commit Messages
- ❌ "progress"
- ❌ "updates"
- ❌ "fixed stuff"
- ❌ "final version"
- ❌ "implemented feature"

## Submission Requirements

### Repository Structure
```
your_username-advanced-notes-app/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   └── utils/
├── README.md (comprehensive)
├── pubspec.yaml
└── analysis_options.yaml
```

### README.md Requirements
- **Project overview** and feature list
- **Setup instructions** (clone, dependencies, run)
- **Flutter version** and prerequisites
- **Architecture decisions** and challenges faced
- **Bonus features** implemented (if any)

### Code Quality Standards
- **Consistent formatting** (dart format)
- **Linter compliance** (analysis_options.yaml)
- **Proper documentation** for complex functions
- **Error handling** throughout the application
