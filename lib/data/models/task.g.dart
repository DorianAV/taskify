// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  date: json['date'] as String?,
  time: json['time'] as String?,
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'date': instance.date,
  'time': instance.time,
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'PENDING',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.completed: 'COMPLETED',
};
