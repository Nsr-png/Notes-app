import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/data/notes_repository_provider.dart';
import 'package:notes_app/features/notes/presentation/screens/note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('affiche le titre et le contenu de la note', (tester) async {
    final container = await _createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NoteScreen(noteId: 'note-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Votre 1ère Note'), findsOneWidget);
    final contentField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Écrire ici...',
      ),
    );
    expect(
      contentField.controller?.text,
      'Bienvenue dans votre application de notes.',
    );
  });

  testWidgets('modifier le contenu met à jour le provider', (tester) async {
    final container = await _createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NoteScreen(noteId: 'note-1')),
      ),
    );
    await tester.pumpAndSettle();
    final contentField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Écrire ici...',
    );
    await tester.enterText(contentField, 'Nouveau contenu');
    await tester.pumpAndSettle();

    expect(
      container.read(notesProvider).requireValue.first.content,
      'Nouveau contenu',
    );
  });
}

Future<ProviderContainer> _createContainer() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final database = AppDatabase(NativeDatabase.memory());
        ref.onDispose(database.close);
        return database;
      }),
      sharedPreferencesProvider.overrideWithValue(preferences),
    ],
  );
}
