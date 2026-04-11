import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/providers/providers.dart';

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return ProjectsNotifier(storage.getAllProjects(), storage);
  },
);

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final dynamic _storage;

  ProjectsNotifier(super.projects, this._storage);

  Future<void> addProject({
    required String name,
    int colorIndex = 0,
    int iconIndex = 0,
    List<String>? tags,
  }) async {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorIndex: colorIndex,
      iconIndex: iconIndex,
      tags: tags,
      sortOrder: state.length,
    );
    await _storage.saveProject(project);
    state = [...state, project];
  }

  Future<void> updateProject(Project project) async {
    await _storage.saveProject(project);
    state = [
      for (final p in state)
        if (p.id == project.id) project else p,
    ];
  }

  Future<void> deleteProject(String id) async {
    await _storage.deleteProject(id);
    state = state.where((p) => p.id != id).toList();
  }

  void refreshFromStorage() {
    state = _storage.getAllProjects();
  }
}
