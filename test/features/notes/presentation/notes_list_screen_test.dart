import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/screens/notes_list_screen.dart';

void main() {
  testWidgets('affiche les titres des quatre notes', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: NotesListScreen())),
    );

    expect(find.text('Idées de projets'), findsOneWidget);
    expect(find.text('Liste de courses'), findsOneWidget);
    expect(find.text('Réunion de lundi'), findsOneWidget);
    expect(find.text('À lire'), findsOneWidget);
  });

  testWidgets('supprime une note et la restaure avec Conserver', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: NotesListScreen())),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('note-1')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Idées de projets'), findsNothing);
    expect(find.text('Note supprimée'), findsOneWidget);
    expect(find.text('Conserver'), findsOneWidget);
    expect(container.read(notesProvider), hasLength(3));

    await tester.tap(find.text('Conserver'));
    await tester.pumpAndSettle();

    expect(container.read(notesProvider), hasLength(4));
    expect(container.read(notesProvider).first.id, 'note-1');
    expect(find.text('Idées de projets'), findsOneWidget);
  });

  testWidgets('un swipe vers la gauche ne supprime pas la note', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: NotesListScreen())),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('note-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Idées de projets'), findsOneWidget);
    expect(container.read(notesProvider), hasLength(4));
    expect(find.text('Note supprimée'), findsNothing);
  });
}
