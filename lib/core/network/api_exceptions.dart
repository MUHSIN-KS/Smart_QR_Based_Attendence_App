import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network connection and server status.',
          statusCode: dioError.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final response = dioError.response;
        final statusCode = response?.statusCode;
        String message = 'An error occurred (${statusCode ?? "unknown"}).';

        if (response?.data != null) {
          if (response!.data is Map<String, dynamic>) {
            final map = response.data as Map<String, dynamic>;
            if (map.containsKey('message')) {
              message = map['message'].toString();
            } else if (map.containsKey('error')) {
              message = map['error'].toString();
            }
          } else if (response.data is String) {
            message = response.data.toString();
          }
        }

        switch (statusCode) {
          case 400:
            // e.g. Expired QR code, Invalid QR code, Check-in required
            return ApiException(message: message, statusCode: 400, data: response?.data);
          case 401:
            // Missing authentication or invalid credentials
            return ApiException(
              message: message.isNotEmpty ? message : 'Unauthorized. Please login again.',
              statusCode: 401,
              data: response?.data,
            );
          case 403:
            // Location not allowed or forbidden
            return ApiException(message: message, statusCode: 403, data: response?.data);
          case 404:
            return ApiException(message: message, statusCode: 404, data: response?.data);
          case 409:
            // Duplicate attendance / already checked in or checked out
            return ApiException(message: message, statusCode: 409, data: response?.data);
          case 500:
            return ApiException(
              message: 'Server error: $message',
              statusCode: 500,
              data: response?.data,
            );
          default:
            return ApiException(message: message, statusCode: statusCode, data: response?.data);
        }

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to the backend server. Please verify the backend is running and the IP address is correct.',
        );

      case DioExceptionType.badCertificate:
        return ApiException(message: 'Invalid SSL certificate.');

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: dioError.message?.contains('SocketException') == true
              ? 'Network error: Cannot reach server.'
              : (dioError.message ?? 'An unexpected network error occurred.'),
        );
    }
  }

  /// Returns true when the error is a network/connection issue (not an HTTP error from the server).
  /// Use this to decide whether to show the "Configure Server IP" prompt.
  bool get isConnectionError =>
      statusCode == null &&
      (message.contains('timed out') ||
          message.contains('connect') ||
          message.contains('reach server') ||
          message.contains('network') ||
          message.contains('SocketException'));

  @override
  String toString() => message;
}

