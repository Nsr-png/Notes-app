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

  test('updateNote modifie la note sans changer les autres', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final originalNotes = container.read(notesProvider);
    final originalOtherNotes = originalNotes.skip(1).toList();

    container
        .read(notesProvider.notifier)
        .updateNote('note-1', content: 'Contenu modifié');
    final updatedNotes = container.read(notesProvider);

    expect(identical(updatedNotes, originalNotes), isFalse);
    expect(updatedNotes.first.content, 'Contenu modifié');
    expect(updatedNotes.first.title, originalNotes.first.title);
    expect(updatedNotes.skip(1), originalOtherNotes);
    expect(
      originalNotes.first.content,
      'Quelques idées à explorer pendant mon temps libre.',
    );
  });

  test('updateNote ne fait rien si l’identifiant est inconnu', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final originalNotes = container.read(notesProvider);

    container
        .read(notesProvider.notifier)
        .updateNote('unknown', title: 'Titre modifié');

    expect(identical(container.read(notesProvider), originalNotes), isTrue);
  });
}
