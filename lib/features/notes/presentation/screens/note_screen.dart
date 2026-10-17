import 'dart:async';

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
  TextEditingController? _titleController;
  TextEditingController? _contentController;

  Note? _findNote(List<Note> notes, String id) {
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(notesProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              const Scaffold(body: Center(child: Text('Erreur de chargement'))),
          data: (notes) {
            final note = _findNote(notes, widget.noteId);
            if (note == null) {
              return const Scaffold(
                body: Center(child: Text('Note introuvable')),
              );
            }

            _titleController ??= TextEditingController(text: note.title);
            _contentController ??= TextEditingController(text: note.content);

            return Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (title) {
                    unawaited(
                      ref
                          .read(notesProvider.notifier)
                          .updateNote(widget.noteId, title: title),
                    );
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
                    unawaited(
                      ref
                          .read(notesProvider.notifier)
                          .updateNote(widget.noteId, content: content),
                    );
                  },
                ),
              ),
            );
          },
        );
  }
}
