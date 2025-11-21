import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable()
class ApiError {
  final String timestamp;
  final int status;
  final String error;
  final String message;
  final String path;
  final Map<String, String>? validationErrors;

  ApiError({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
    this.validationErrors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  String get message => error.message;
  Map<String, String>? get validationErrors => error.validationErrors;

  @override
  String toString() => message;
}
