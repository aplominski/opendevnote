import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opendevnote/app.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/models/todo_item.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(TodoItemAdapter());
    await Hive.openBox<Project>('projects');
    await Hive.openBox<TodoItem>('todos');

    await tester.pumpWidget(const ProviderScope(child: OpenDevNoteApp()));

    expect(find.text('OpenDevNote'), findsOneWidget);
  });
}
