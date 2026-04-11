import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opendevnote/models/code_snippet.dart';
import 'package:opendevnote/providers/providers.dart';

const _uuid = Uuid();

final snippetsProvider = StateNotifierProvider.family<SnippetsNotifier, List<CodeSnippet>, String>((ref, projectId) {
  final storage = ref.watch(storageServiceProvider);
  return SnippetsNotifier(projectId, storage.getSnippetsForProject(projectId), storage);
});

class SnippetsNotifier extends StateNotifier<List<CodeSnippet>> {
  final String _projectId;
  final dynamic _storage;

  SnippetsNotifier(this._projectId, super.snippets, this._storage);

  Future<void> addSnippet({
    required String title,
    required String language,
    String code = '',
    String? linkedTaskId,
    String? description,
  }) async {
    final snippet = CodeSnippet(
      id: _uuid.v4(),
      projectId: _projectId,
      title: title,
      code: code,
      language: language,
      sortOrder: state.length,
      linkedTaskId: linkedTaskId,
      description: description,
    );
    await _storage.saveSnippet(snippet);
    state = [snippet, ...state];
  }

  Future<void> updateSnippet(CodeSnippet snippet) async {
    final updated = snippet.copyWith();
    await _storage.saveSnippet(updated);
    state = [
      updated,
      for (final s in state) if (s.id != snippet.id) s,
    ];
  }

  Future<void> deleteSnippet(String id) async {
    await _storage.deleteSnippet(id);
    state = state.where((s) => s.id != id).toList();
  }
}
