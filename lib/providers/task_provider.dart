import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../utils/error_handler.dart';
import 'providers.dart';

enum TaskFilter { all, pending, inProgress, completed }

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String>? validationErrors;
  final TaskFilter filter;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.validationErrors,
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
    Map<String, String>? validationErrors,
    TaskFilter? filter,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> addTask(String title, String description, TaskStatus status, String? date, String? time) async {
    try {
      var newTask = await _taskRepository.createTask(title, description, status, date, time);
      
      // Workaround: If server ignores status (defaults to PENDING), update it immediately
      if (newTask.status != status) {
        final updatedTask = newTask.copyWith(status: status);
        // We need the ID to update, assuming createTask returns a task with ID
        if (updatedTask.id != null) {
           await _taskRepository.updateTask(updatedTask);
           newTask = updatedTask;
        }
      }
      
      state = state.copyWith(tasks: [...state.tasks, newTask]);
    } catch (e) {
      state = state.copyWith(
        errorMessage: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _taskRepository.updateTask(task);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _taskRepository.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: ErrorHandler.getErrorMessage(e));
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
