import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/notes/data/notes_repository_provider.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repository = ref.watch(notesRepositoryProvider);
    final notes = await repository.getAllNotes();
    if (notes.isNotEmpty) return notes;

    final preferences = ref.watch(sharedPreferencesProvider);
    if (preferences.getBool('welcome_note_created') ?? false) return notes;

    final initialNote = Note(
      id: 'note-1',
      title: 'Votre 1ère Note',
      content: 'Bienvenue dans votre application de notes.',
      updatedAt: DateTime.now(),
    );
    await repository.insertNote(initialNote);
    await preferences.setBool('welcome_note_created', true);
    return [initialNote];
  }

  Future<void> createNote(Note note) async {
    await ref.read(notesRepositoryProvider).insertNote(note);
    state = AsyncData([note, ...state.requireValue]);
  }

  Future<void> addNote(Note note) => createNote(note);

  Future<void> updateNote(String id, {String? title, String? content}) async {
    final notes = state.requireValue;
    final noteIndex = notes.indexWhere((note) => note.id == id);
    if (noteIndex == -1) return;

    final updatedNotes = [...notes];
    final updatedNote = updatedNotes[noteIndex].copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    await ref.read(notesRepositoryProvider).updateNote(updatedNote);
    updatedNotes[noteIndex] = updatedNote;
    state = AsyncData(updatedNotes);
  }

  Future<({Note note, int index})?> deleteNote(String id) async {
    final notes = state.requireValue;
    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1) return null;

    final updatedNotes = [...notes];
    final note = updatedNotes.removeAt(index);
    await ref.read(notesRepositoryProvider).deleteNote(id);
    state = AsyncData(updatedNotes);
    return (note: note, index: index);
  }

  Future<void> restoreNote(Note note, int index) async {
    await ref.read(notesRepositoryProvider).insertNote(note);
    final updatedNotes = [...state.requireValue];
    final insertionIndex = index.clamp(0, updatedNotes.length);
    updatedNotes.insert(insertionIndex, note);
    state = AsyncData(updatedNotes);
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);
