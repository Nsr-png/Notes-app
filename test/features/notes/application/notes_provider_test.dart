import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/data/notes_repository_provider.dart';
import 'package:notes_app/features/notes/domain/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('l’état initial contient une note Votre 1ère Note', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());

    final notes = await container.read(notesProvider.future);
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Votre 1ère Note');
    expect(
      container.read(sharedPreferencesProvider).getBool('welcome_note_created'),
      isTrue,
    );
  });

  test(
    'n’insère pas la note d’accueil si la préférence est déjà vraie',
    () async {
      final container = await _createContainer(
        initialPreferences: {'welcome_note_created': true},
      );
      addTearDown(() => container.dispose());

      expect(await container.read(notesProvider.future), isEmpty);
      expect(
        await container.read(notesRepositoryProvider).getAllNotes(),
        isEmpty,
      );
    },
  );

  test('createNote place la nouvelle note au début de la liste', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    await container.read(notesProvider.future);
    final note = Note(
      id: 'note-new',
      title: 'Nouvelle note',
      content: 'Contenu',
      updatedAt: DateTime(2026, 10, 17),
    );

    await container.read(notesProvider.notifier).createNote(note);
    final updatedNotes = container.read(notesProvider).requireValue;

    expect(updatedNotes, hasLength(2));
    expect(updatedNotes.first, note);
  });

  test('updateNote modifie la note sans changer les autres', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    final originalNotes = await container.read(notesProvider.future);
    final originalOtherNotes = originalNotes.skip(1).toList();

    await container
        .read(notesProvider.notifier)
        .updateNote('note-1', content: 'Contenu modifié');
    final updatedNotes = container.read(notesProvider).requireValue;

    expect(identical(updatedNotes, originalNotes), isFalse);
    expect(updatedNotes.first.content, 'Contenu modifié');
    expect(updatedNotes.first.title, originalNotes.first.title);
    expect(updatedNotes.skip(1), originalOtherNotes);
    expect(
      originalNotes.first.content,
      'Bienvenue dans votre application de notes.',
    );
  });

  test('updateNote ne fait rien si l’identifiant est inconnu', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    final originalNotes = await container.read(notesProvider.future);

    await container
        .read(notesProvider.notifier)
        .updateNote('unknown', title: 'Titre modifié');

    expect(
      identical(container.read(notesProvider).requireValue, originalNotes),
      isTrue,
    );
  });

  test('deleteNote retire la note et retourne sa position', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    final originalNotes = await container.read(notesProvider.future);

    final deleted = await container
        .read(notesProvider.notifier)
        .deleteNote('note-1');

    expect(deleted?.note, originalNotes.single);
    expect(deleted?.index, 0);
    expect(container.read(notesProvider).requireValue, isEmpty);
    expect(originalNotes, hasLength(1));
  });

  test('deleteNote ne change rien si l’identifiant est inconnu', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    final originalNotes = await container.read(notesProvider.future);

    final deleted = await container
        .read(notesProvider.notifier)
        .deleteNote('unknown');

    expect(deleted, isNull);
    expect(
      identical(container.read(notesProvider).requireValue, originalNotes),
      isTrue,
    );
  });

  test('restoreNote réinsère la note à sa position d’origine', () async {
    final container = await _createContainer();
    addTearDown(() => container.dispose());
    final originalNotes = await container.read(notesProvider.future);
    final notifier = container.read(notesProvider.notifier);

    final deleted = (await notifier.deleteNote('note-1'))!;
    await notifier.restoreNote(deleted.note, deleted.index);

    expect(container.read(notesProvider).requireValue, hasLength(1));
    expect(
      container.read(notesProvider).requireValue.single,
      originalNotes.single,
    );
  });
}

Future<ProviderContainer> _createContainer({
  Map<String, Object> initialPreferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final database = AppDatabase(NativeDatabase.memory());
        ref.onDispose(() => unawaited(database.close()));
        return database;
      }),
      sharedPreferencesProvider.overrideWithValue(preferences),
    ],
  );
}
