import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/screens/notes_list_screen.dart';

void main() {
  testWidgets('affiche le titre de la note initiale', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: NotesListScreen())),
    );

    expect(find.text('Votre 1ère Note'), findsOneWidget);
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

    expect(find.text('Votre 1ère Note'), findsNothing);
    expect(find.text('Note supprimée'), findsOneWidget);
    expect(find.text('Conserver'), findsOneWidget);
    expect(container.read(notesProvider), isEmpty);

    await tester.tap(find.text('Conserver'));
    await tester.pumpAndSettle();
    expect(container.read(notesProvider), hasLength(1));
    expect(container.read(notesProvider).first.id, 'note-1');
    expect(find.text('Votre 1ère Note'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('note-1')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Note supprimée'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Note supprimée'), findsNothing);
    expect(container.read(notesProvider), isEmpty);
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

    expect(find.text('Votre 1ère Note'), findsOneWidget);
    expect(container.read(notesProvider), hasLength(1));
    expect(find.text('Note supprimée'), findsNothing);
  });
}
