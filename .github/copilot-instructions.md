# AI Coding Agent Instructions for Notes App

## Project Overview
This is a Flutter note-taking app using **GetX state management**, **SQLite local storage**, and **Flutter Quill** for rich text editing. The app follows a clean MVC architecture with reactive programming patterns.

## Architecture Patterns

### GetX-based MVC Structure
```
lib/
├── controllers/     # GetX controllers for state management
├── models/         # Data models with SQLite mapping
├── views/          # Screen widgets (UI)
├── data/local/     # Database layer (SQLite)
├── utility/        # Themes, constants, helpers
└── widgets/        # Reusable UI components
```

### Core Dependencies & Integration Points
- **GetX**: All state management uses `.obs` reactive variables and `GetxController`
- **SQLite**: Database operations through singleton `DatabaseHelper` class
- **Flutter Quill**: Rich text content stored as JSON in SQLite `content` field
- **Google Fonts**: Consistent Poppins typography via `Themes` class

### State Management Patterns

**Controller Architecture**: All controllers extend `GetxController` and are initialized in `AppBindings`:
```dart
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteController());
    Get.lazyPut(() => ThemeController());
  }
}
```

**Reactive Data Flow**: Controllers use `.obs` variables and automatic UI rebuilds:
```dart
final notes = <Note>[].obs;
final isLoading = true.obs;
final searchQuery = ''.obs;
```

### Database Layer

**Singleton Pattern**: `DatabaseHelper` is a singleton injected globally in `main.dart`:
```dart
final dbHelper = DatabaseHelper();
Get.put<DatabaseHelper>(dbHelper, permanent: true);
```

**Model-Database Mapping**: All models implement `toMap()` and `fromMap()` for SQLite serialization:
```dart
Map<String, dynamic> toMap() {
  return {
    'isFavorite': isFavorite ? 1 : 0, // Boolean to INTEGER conversion
    'createdAt': createdAt.toIso8601String(), // DateTime serialization
  };
}
```

### Content Management

**Rich Text Storage**: Flutter Quill documents are stored as JSON strings in SQLite:
```dart
// Saving: Document -> JSON -> SQLite
final jsonContent = jsonEncode(_quillController.document.toDelta().toJson());

// Loading: SQLite -> JSON -> Document  
Document.fromJson(jsonDecode(note.content))
```

## Development Workflows

### Adding New Features
1. **Model First**: Create/update model in `models/` with proper `toMap()`/`fromMap()`
2. **Database Schema**: Update `DatabaseHelper._createDB()` for new fields
3. **Controller Logic**: Add reactive methods to relevant controller
4. **UI Integration**: Use `Obx()` widgets for reactive UI updates

### Testing Database Changes
```bash
flutter clean && flutter pub get
# Database recreated on first app launch after schema changes
```

### Theme Customization
All styling goes through `utility/themes.dart` with separate light/dark themes:
- Primary colors: `#08C27B` (green) and `#000B07` (dark green/black) for light mode
- Typography: Google Fonts Poppins family
- Cards: 24px border radius with modern shadows and gradients
- Modern glass-morphism effects with subtle animations

### UI Design Patterns
- **Note Cards**: Modern design with gradient backgrounds, enhanced shadows, and animated interactions
- **Action Buttons**: Clean, modern buttons with proper states and micro-interactions
- **Confirmation Dialogs**: Beautiful, accessible dialogs with clear visual hierarchy
- **Animations**: Smooth transitions and hover effects for better UX

### Navigation Pattern
Uses GetX routing with `MainNavigationView` as the main container:
```dart
Get.to(() => CreateNoteView(note: selectedNote)); // Navigation
Get.back(); // Return after operations
```

### Ad Integration

**AdMob Integration**: The app uses Google Mobile Ads with the following configuration:
- **Interstitial Ad**: `ca-app-pub-2744970719381152/2955320728`
- **Banner Ad**: `ca-app-pub-2744970719381152/4164102489`
- **Ad Service**: Singleton service `AdService` manages all ad operations
- **Banner Placement**: Bottom of main navigation and between notes (every 3 notes)
- **Interstitial Triggers**: Save actions (30% chance) and navigation (every 7 taps)

## Critical Implementation Details

### Search Functionality
Search operates on separate `searchedNotes` observable list alongside main `notes` list, with category filtering applied to both result sets.

### Boolean Database Fields  
SQLite stores booleans as INTEGER (0/1). Always use ternary conversion:
```dart
'isFavorite': isFavorite ? 1 : 0  // Writing
isFavorite: map['isFavorite'] == 1  // Reading
```

### Error Handling Pattern
All async operations use try-catch with GetX snackbars:
```dart
try {
  await operation();
  Get.snackbar('Success', 'Operation completed');
} catch (e) {
  Get.snackbar('Error', 'Operation failed: ${e.toString()}');
}
```

### Performance Considerations
- Database queries use indexed ordering: `ORDER BY isPinned DESC, updatedAt DESC`
- UI uses `IndexedStack` for navigation to preserve state
- Controllers are lazy-loaded but database connection is permanent

When implementing new features, always follow the GetX reactive patterns, maintain the singleton database architecture, and ensure proper JSON serialization for Flutter Quill content.