import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/domain/note.dart';

final notes = List<Note>.unmodifiable([
  Note(
    id: 'note-1',
    title: 'Idées de projets',
    content: 'Quelques idées à explorer pendant mon temps libre.',
    updatedAt: DateTime(2026, 10, 15),
  ),
  Note(
    id: 'note-2',
    title: 'Liste de courses',
    content: 'Pain, lait, pommes et café.',
    updatedAt: DateTime(2026, 10, 14),
  ),
  Note(
    id: 'note-3',
    title: 'Réunion de lundi',
    content: 'Préparer le bilan et les sujets à discuter avec l’équipe.',
    updatedAt: DateTime(2026, 10, 12),
  ),
  Note(
    id: 'note-4',
    title: 'À lire',
    content: 'Noter les livres recommandés par mes amis.',
    updatedAt: DateTime(2026, 10, 10),
  ),
]);

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes notes')),
      body: notes.isEmpty
          ? const Center(child: Text('Aucune note pour le moment'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('Modifiée le ${_formatDate(note.updatedAt)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
