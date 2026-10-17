import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/screens/note_screen.dart';

void main() {
  testWidgets('affiche le titre et le contenu de la note', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NoteScreen(noteId: 'note-1')),
      ),
    );

    expect(find.widgetWithText(TextField, 'Idées de projets'), findsOneWidget);
    expect(
      find.widgetWithText(
        TextField,
        'Quelques idées à explorer pendant mon temps libre.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('modifier le contenu met à jour le provider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NoteScreen(noteId: 'note-1')),
      ),
    );
    final contentField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Écrire ici...',
    );
    await tester.enterText(contentField, 'Nouveau contenu');

    expect(container.read(notesProvider).first.content, 'Nouveau contenu');
  });
}
