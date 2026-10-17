import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() => [
    Note(
      id: 'note-1',
      title: 'Idées de projets',
      content: 'Quelques idées à explorer pendant mon temps libre.',
      updatedAt: DateTime(2026, 10, 15),
    ),
    Note(
      id: 'note-2',
      title: 'Liste de courses',
      content: 'Pain, lait, pommes et café.',
      updatedAt: DateTime(2026, 10, 14),
    ),
    Note(
      id: 'note-3',
      title: 'Réunion de lundi',
      content: 'Préparer le bilan et les sujets à discuter avec l’équipe.',
      updatedAt: DateTime(2026, 10, 12),
    ),
    Note(
      id: 'note-4',
      title: 'À lire',
      content: 'Noter les livres recommandés par mes amis.',
      updatedAt: DateTime(2026, 10, 10),
    ),
  ];

  void addNote(Note note) {
    state = [note, ...state];
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);
