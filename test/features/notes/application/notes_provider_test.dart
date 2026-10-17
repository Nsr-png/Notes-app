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

  test('deleteNote retire la note et retourne sa position', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final originalNotes = container.read(notesProvider);

    final deleted = container.read(notesProvider.notifier).deleteNote('note-2');

    expect(deleted?.note, originalNotes[1]);
    expect(deleted?.index, 1);
    expect(container.read(notesProvider), [
      originalNotes[0],
      originalNotes[2],
      originalNotes[3],
    ]);
    expect(originalNotes, hasLength(4));
  });

  test('deleteNote ne change rien si l’identifiant est inconnu', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final originalNotes = container.read(notesProvider);

    final deleted = container
        .read(notesProvider.notifier)
        .deleteNote('unknown');

    expect(deleted, isNull);
    expect(identical(container.read(notesProvider), originalNotes), isTrue);
  });

  test('restoreNote réinsère la note à sa position d’origine', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final originalNotes = container.read(notesProvider);
    final notifier = container.read(notesProvider.notifier);

    final deleted = notifier.deleteNote('note-2')!;
    notifier.restoreNote(deleted.note, deleted.index);

    expect(container.read(notesProvider), originalNotes);
  });
}
