import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/screens/note_screen.dart';
import 'package:notes_app/features/notes/presentation/screens/notes_list_screen.dart';

void main() {
  testWidgets('un titre vide affiche une erreur sans ajouter de note', (
    tester,
  ) async {
    final container = ProviderContainer();
    final router = _createRouter();
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.byTooltip('Ajouter une note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer'));
    await tester.pump();

    expect(find.text('Le titre ne peut pas être vide'), findsOneWidget);
    expect(container.read(notesProvider), hasLength(4));
  });

  testWidgets('un titre saisi ajoute une note au provider', (tester) async {
    final container = ProviderContainer();
    final router = _createRouter();
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.byTooltip('Ajouter une note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ma nouvelle note');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    final notes = container.read(notesProvider);
    expect(notes, hasLength(5));
    expect(notes.first.title, 'Ma nouvelle note');
  });
}

GoRouter _createRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const NotesListScreen()),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) =>
            NoteScreen(noteId: state.pathParameters['id']!),
      ),
    ],
  );
}
