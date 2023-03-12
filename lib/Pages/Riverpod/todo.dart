import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/rendering.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class Todo {
  const Todo(
      {required this.id, required this.description, this.completed = false});
  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

class TodoList extends StateNotifier<List<Todo>> {
  TodoList([List<Todo>? initialToods]) : super(initialToods ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
      )
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
              id: todo.id,
              description: todo.description,
              completed: !todo.completed)
        else
          todo
    ];
  }

  void edit({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: id,
            description: description,
            completed: todo.completed,
          )
        else
          todo
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}
