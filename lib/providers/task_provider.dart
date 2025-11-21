import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import 'providers.dart';

enum TaskFilter { all, pending, inProgress, completed }

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;
  final TaskFilter filter;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter = TaskFilter.all,
  });

  List<Task> get filteredTasks {
    if (filter == TaskFilter.all) return tasks;
    return tasks.where((task) {
      switch (filter) {
        case TaskFilter.pending:
          return task.status == TaskStatus.pending;
        case TaskFilter.inProgress:
          return task.status == TaskStatus.inProgress;
        case TaskFilter.completed:
          return task.status == TaskStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
    TaskFilter? filter,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _taskRepository;

  TaskNotifier(this._taskRepository) : super(TaskState());

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _taskRepository.getTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      final newTask = await _taskRepository.createTask(title, description);
      state = state.copyWith(tasks: [...state.tasks, newTask]);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _taskRepository.updateTask(task);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _taskRepository.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(taskRepository);
});
