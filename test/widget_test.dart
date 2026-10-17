import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes_app/core/database/app_database.dart';
import 'package:notes_app/features/notes/data/notes_repository_provider.dart';
import 'package:notes_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('affiche le titre Mes notes', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mes notes'), findsOneWidget);
  });
}
