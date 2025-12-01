import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'task.g.dart';

enum TaskStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
}

enum TaskPriority {
  @JsonValue('HIGH')
  high,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('LOW')
  low,
}

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final String? date;
  final String? time;
  final TaskPriority priority;
  final String color; // Hex string e.g. "#FF0000"

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    this.date,
    this.time,
    this.priority = TaskPriority.medium,
    this.color = '#6C63FF', // Default purple
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    String? date,
    String? time,
    TaskPriority? priority,
    String? color,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      color: color ?? this.color,
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

  String getPriorityLabel() {
    switch (priority) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }

  Color getParsedColor() {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }
}
