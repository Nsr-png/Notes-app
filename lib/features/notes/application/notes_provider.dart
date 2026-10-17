import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() => [
    Note(
      id: 'note-1',
      title: 'Votre 1ère Note',
      content: '',
      updatedAt: DateTime(2026, 10, 15),
    )
  ];

  void addNote(Note note) {
    state = [note, ...state];
  }

  void updateNote(String id, {String? title, String? content}) {
    final noteIndex = state.indexWhere((note) => note.id == id);
    if (noteIndex == -1) return;

    final updatedNotes = [...state];
    updatedNotes[noteIndex] = updatedNotes[noteIndex].copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    state = updatedNotes;
  }

  ({Note note, int index})? deleteNote(String id) {
    final index = state.indexWhere((note) => note.id == id);
    if (index == -1) return null;

    final updatedNotes = [...state];
    final note = updatedNotes.removeAt(index);
    state = updatedNotes;
    return (note: note, index: index);
  }

  void restoreNote(Note note, int index) {
    final updatedNotes = [...state];
    final insertionIndex = index.clamp(0, updatedNotes.length);
    updatedNotes.insert(insertionIndex, note);
    state = updatedNotes;
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);
