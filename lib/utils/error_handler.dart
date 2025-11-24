import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(Object error, {bool isLogin = false, bool isRegister = false}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'Verifique su conexión a internet';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (isLogin) {
              if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
                return 'Verifique usuario o contraseña';
              }
            }
            if (isRegister) {
              if (statusCode == 403 || statusCode == 409) {
                return 'Ese usuario ya existe';
              }
            }
            
            switch (statusCode) {
              case 400:
                return 'Solicitud incorrecta';
              case 401:
                return 'No autorizado';
              case 403:
                return 'Acceso denegado';
              case 404:
                return 'Recurso no encontrado';
              case 500:
                return 'Error interno del servidor';
              case 503:
                return 'Servicio no disponible';
            }
          }
          return 'Error del servidor (${statusCode ?? "Desconocido"})';
        case DioExceptionType.cancel:
          return 'Solicitud cancelada';
        case DioExceptionType.unknown:
          if (error.message != null && error.message!.contains('SocketException')) {
            return 'Verifique su conexión a internet';
          }
          return 'Error inesperado';
        default:
          return 'Ocurrió un error de conexión';
      }
    }
    return 'Ocurrió un error inesperado';
  }
}
