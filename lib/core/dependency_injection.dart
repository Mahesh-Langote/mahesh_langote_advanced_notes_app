import 'package:get_it/get_it.dart';
import '../services/services.dart';

/// Service locator instance
/// Used for dependency injection throughout the application
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
/// Call this method in main.dart before runApp()
Future<void> initializeDependencies() async {
  // Register NotesService as a singleton
  serviceLocator.registerLazySingleton<NotesService>(
    () => NotesService(),
  );

  // Initialize the NotesService
  await serviceLocator<NotesService>().initialize();
}
