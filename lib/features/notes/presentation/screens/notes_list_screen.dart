import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes/application/notes_provider.dart';
import 'package:notes_app/features/notes/domain/note.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            onPressed: () => _showCreateNoteDialog(context, ref),
            tooltip: 'Ajouter une note',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Erreur de chargement')),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Aucune note pour le moment'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) async {
                      final result = await ref
                          .read(notesProvider.notifier)
                          .deleteNote(note.id);
                      if (result == null || !context.mounted) return;

                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          persist: false,
                          content: const Text('Note supprimée'),
                          action: SnackBarAction(
                            label: 'Conserver',
                            onPressed: () {
                              unawaited(
                                ref
                                    .read(notesProvider.notifier)
                                    .restoreNote(result.note, result.index),
                              );
                            },
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => context.push('/notes/${note.id}'),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}

Future<void> _showCreateNoteDialog(BuildContext context, WidgetRef ref) async {
  final titleController = TextEditingController();
  String? titleError;
  String? createdNoteId;
  Completer<void>? dialogClosed;

  try {
    createdNoteId = await showDialog<String>(
      context: context,
      barrierColor: Colors.black38,
      builder: (dialogContext) {
        final animation = ModalRoute.of(dialogContext)?.animation;
        if (animation != null) {
          dialogClosed = Completer<void>();
          void onStatusChange(AnimationStatus status) {
            if (status == AnimationStatus.dismissed &&
                !dialogClosed!.isCompleted) {
              animation.removeStatusListener(onStatusChange);
              dialogClosed!.complete();
            }
          }

          animation.addStatusListener(onStatusChange);
        }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: StatefulBuilder(
                    builder: (context, setDialogState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Titre',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextField(
                          controller: titleController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Donne un titre à ta note',
                            errorText: titleError,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                final title = titleController.text.trim();
                                if (title.isEmpty) {
                                  setDialogState(() {
                                    titleError =
                                        'Le titre ne peut pas être vide';
                                  });
                                  return;
                                }

                                final now = DateTime.now();
                                final note = Note(
                                  id: 'note-${now.microsecondsSinceEpoch}',
                                  title: title,
                                  content: '',
                                  updatedAt: now,
                                );
                                await ref
                                    .read(notesProvider.notifier)
                                    .createNote(note);
                                if (!dialogContext.mounted) return;
                                Navigator.of(dialogContext).pop(note.id);
                              },
                              child: const Text('Créer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    await dialogClosed?.future;
  } finally {
    titleController.dispose();
  }

  if (createdNoteId != null && context.mounted) {
    context.push('/notes/$createdNoteId');
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
