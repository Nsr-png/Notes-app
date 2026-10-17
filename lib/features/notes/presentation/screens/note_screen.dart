import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late final Note? _note;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _note = _findNote(ref.read(notesProvider), widget.noteId);
    _titleController = TextEditingController(text: _note?.title ?? '');
    _contentController = TextEditingController(text: _note?.content ?? '');
  }

  Note? _findNote(List<Note> notes, String id) {
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return const Scaffold(body: Center(child: Text('Note introuvable')));
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (title) {
            ref
                .read(notesProvider.notifier)
                .updateNote(widget.noteId, title: title);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            hintText: 'Écrire ici...',
            border: InputBorder.none,
          ),
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (content) {
            ref
                .read(notesProvider.notifier)
                .updateNote(widget.noteId, content: content);
          },
        ),
      ),
    );
  }
}
