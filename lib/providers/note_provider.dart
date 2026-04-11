import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opendevnote/models/note.dart';
import 'package:opendevnote/providers/providers.dart';

const _uuid = Uuid();

final notesProvider =
    StateNotifierProvider.family<NotesNotifier, List<Note>, String>((
      ref,
      projectId,
    ) {
      final storage = ref.watch(storageServiceProvider);
      return NotesNotifier(
        projectId,
        storage.getNotesForProject(projectId),
        storage,
      );
    });

class NotesNotifier extends StateNotifier<List<Note>> {
  final String _projectId;
  final dynamic _storage;

  NotesNotifier(this._projectId, super.notes, this._storage);

  Future<void> addNote({
    required String title,
    String content = '',
    String? linkedTaskId,
  }) async {
    final note = Note(
      id: _uuid.v4(),
      projectId: _projectId,
      title: title,
      content: content,
      sortOrder: state.length,
      linkedTaskId: linkedTaskId,
    );
    await _storage.saveNote(note);
    state = [note, ...state];
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith();
    await _storage.saveNote(updated);
    state = [
      updated,
      for (final n in state)
        if (n.id != note.id) n,
    ];
  }

  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}
