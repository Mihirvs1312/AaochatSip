import 'dart:io';

import 'package:callingproject/src/utils/app_settings.dart';
import 'package:callingproject/src/utils/constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum DioMethod { post, get, put, delete }

class ApiClient {
  ApiClient._singleton();

  static final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppSettings.BASED_URL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    )
    ..interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print(obj),
      ),
    ]);

  static final ApiClient instance = ApiClient._singleton();

  Future<Response> request(
    String endpoint,
    DioMethod method, {
    Map<String, dynamic>? param,
    formData,
  }) async {
    String? mToken = await SecureStorage().read(Constants.TOKEN);
    try {
      final dio = Dio(
          BaseOptions(
            baseUrl: AppSettings.BASED_URL,
            contentType: Headers.jsonContentType,
            headers: {HttpHeaders.authorizationHeader: 'Bearer $mToken'},
          ),
        )
        ..interceptors.addAll([
          AuthInterceptor(),
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            logPrint: (obj) => print(obj),
          ),
        ]);
      switch (method) {
        case DioMethod.post:
          return dio.post(endpoint, data: param ?? formData);
        case DioMethod.get:
          return dio.get(endpoint, queryParameters: param);
        case DioMethod.put:
          return dio.put(endpoint, data: param ?? formData);
        case DioMethod.delete:
          return dio.delete(endpoint, data: param ?? formData);
        default:
          return dio.post(endpoint, data: param ?? formData);
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }
}

class AuthInterceptor extends Interceptor {
  // Simulate token access; replace with secure storage
  final String? _accessToken = "await SecureStorage().read(Constants.TOKEN);";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null) {
      options.headers["Authorization"] = "Bearer $_accessToken";
      options.contentType = Headers.formUrlEncodedContentType;
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token refresh, logging, or custom errors
    super.onError(err, handler);
  }
}
