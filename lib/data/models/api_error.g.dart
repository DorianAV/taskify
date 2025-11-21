// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  timestamp: json['timestamp'] as String,
  status: (json['status'] as num).toInt(),
  error: json['error'] as String,
  message: json['message'] as String,
  path: json['path'] as String,
  validationErrors: (json['validationErrors'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'status': instance.status,
  'error': instance.error,
  'message': instance.message,
  'path': instance.path,
  'validationErrors': instance.validationErrors,
};
