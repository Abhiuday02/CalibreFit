import 'package:calibrefit/core/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Shared Dio HTTP client factory.
///
/// Returns a pre-configured [Dio] instance. In later phases a base URL and
/// interceptors (auth token injection, logging, retry) will be added here.
Dio createDioClient() {
  final options = BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  );

  final dio = Dio(options);

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  return dio;
}

/// Maps a [DioException] to a typed [AppFailure].
AppFailure dioExceptionToFailure(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => const NetworkFailure(
      message: 'Connection timed out. Check your internet.',
    ),
    DioExceptionType.badResponse => NetworkFailure(
      message: e.response?.statusMessage ?? 'Server error.',
      statusCode: e.response?.statusCode,
    ),
    DioExceptionType.connectionError => const NetworkFailure(
      message: 'No internet connection.',
    ),
    _ => NetworkFailure(message: e.message ?? 'Unknown network error.'),
  };
}
