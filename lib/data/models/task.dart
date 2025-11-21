import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

enum TaskStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
}

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  String getStatusLabel() {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completada';
    }
  }

  static String getStatusLabelStatic(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completada';
    }
  }
}
