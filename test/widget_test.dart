import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes_app/main.dart';

void main() {
  testWidgets('affiche le titre Mes notes', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('Mes notes'), findsOneWidget);
  });
}
