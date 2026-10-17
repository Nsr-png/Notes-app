import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/data/notes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(appDatabaseProvider));
});
