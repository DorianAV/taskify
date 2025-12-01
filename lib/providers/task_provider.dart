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
  final String searchQuery;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.validationErrors,
    this.filter = TaskFilter.all,
    this.searchQuery = '',
  });

  List<Task> get filteredTasks {
    return tasks.where((task) {
      // 1. Filter by Status
      bool matchesStatus = true;
      if (filter != TaskFilter.all) {
        switch (filter) {
          case TaskFilter.pending:
            matchesStatus = task.status == TaskStatus.pending;
            break;
          case TaskFilter.inProgress:
            matchesStatus = task.status == TaskStatus.inProgress;
            break;
          case TaskFilter.completed:
            matchesStatus = task.status == TaskStatus.completed;
            break;
          default:
            matchesStatus = true;
        }
      }

      // 2. Filter by Search Query
      bool matchesQuery = true;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        matchesQuery = task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }

      return matchesStatus && matchesQuery;
    }).toList();
  }

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? validationErrors,
    TaskFilter? filter,
    String? searchQuery,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
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

  Future<void> addTask(String title, String description, TaskStatus status, String? date, String? time, TaskPriority priority, String color) async {
    try {
      var newTask = await _taskRepository.createTask(title, description, status, date, time, priority, color);
      
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(taskRepository);
});
