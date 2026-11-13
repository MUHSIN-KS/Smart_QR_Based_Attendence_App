import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveDefaultBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // If a custom base URL has been set in preferences, use it
          final customUrl = _storageService.getBaseUrl();
          if (customUrl != null && customUrl.trim().isNotEmpty) {
            options.baseUrl = customUrl.trim();
          }

          // Attach JWT token if available
          final token = _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[API-REQ] ${options.method} ${options.baseUrl}${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API-RES] ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint('[API-ERR] ${error.response?.statusCode} ${error.requestOptions.path} : ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  String _resolveDefaultBaseUrl() {
    final saved = _storageService.getBaseUrl();
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    if (kIsWeb) {
      return AppConstants.defaultLocalhostUrl;
    }

    // For Android, default to the PC's Wi-Fi LAN IP so it works directly
    if (Platform.isAndroid) {
      return AppConstants.defaultLanUrl;
    }

    // iOS Simulator, Windows desktop, macOS, Linux
    return AppConstants.defaultLocalhostUrl;
  }

  /// True when no base URL has been configured yet by the user.
  bool get needsServerConfig {
    final saved = _storageService.getBaseUrl();
    return saved == null || saved.isEmpty;
  }

  String get currentBaseUrl => _storageService.getBaseUrl() ?? _resolveDefaultBaseUrl();

  Future<void> updateBaseUrl(String newUrl) async {
    await _storageService.saveBaseUrl(newUrl);
    _dio.options.baseUrl = newUrl;
  }

  // HTTP GET
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // HTTP POST
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // HTTP PUT
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}

