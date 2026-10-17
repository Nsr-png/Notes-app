import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/domain/note.dart';

void main() {
  test('l’état initial contient quatre notes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(notesProvider), hasLength(4));
  });

  test('addNote place la nouvelle note au début de la liste', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final note = Note(
      id: 'note-new',
      title: 'Nouvelle note',
      content: 'Contenu',
      updatedAt: DateTime(2026, 10, 17),
    );

    container.read(notesProvider.notifier).addNote(note);
    final updatedNotes = container.read(notesProvider);

    expect(updatedNotes, hasLength(5));
    expect(updatedNotes.first, note);
  });
}
