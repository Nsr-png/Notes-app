import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes/presentation/screens/notes_list_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesListScreen()),
  ],
);
