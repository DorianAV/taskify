import '../api/api_service.dart';
import '../models/task.dart';

class TaskRepository {
  final ApiService _apiService;

  TaskRepository(this._apiService);

  Future<List<Task>> getTasks() async {
    return await _apiService.getTasks();
  }

  Future<Task> createTask(String title, String description, TaskStatus status, String? date, String? time) async {
    final task = Task(
      title: title,
      description: description,
      status: status,
      date: date,
      time: time,
    );
    return await _apiService.createTask(task);
  }

  Future<Task> updateTask(Task task) async {
    if (task.id == null) throw Exception('Task ID is null');
    return await _apiService.updateTask(task.id!, task);
  }

  Future<void> deleteTask(int id) async {
    await _apiService.deleteTask(id);
  }
}
