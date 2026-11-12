import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.yourdomain.com', // Update with actual URL later
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // We will inject JWT tokens here in Phase 2
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint('API Error [${e.response?.statusCode}]: ${e.message}');
        return handler.next(e);
      },
    ));
  }
}