import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_error.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://8aff63b27abc.ngrok-free.app', // Android Emulator
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Parse backend error response
          if (e.response != null && e.response!.data != null) {
            try {
              final apiError = ApiError.fromJson(e.response!.data);
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  response: e.response,
                  type: e.type,
                  error: ApiException(apiError),
                ),
              );
            } catch (_) {
              // If parsing fails, continue with original error
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
