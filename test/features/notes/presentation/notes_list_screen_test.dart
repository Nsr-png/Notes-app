import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
