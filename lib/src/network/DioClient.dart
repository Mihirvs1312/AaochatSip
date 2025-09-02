import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/Constants.dart';
import '../utils/app_settings.dart';
import '../utils/secure_storage.dart';

class DioClient {
  static final DioClient instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return instance;
  }

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: AppSettings.BASED_URL,
      connectTimeout: const Duration(seconds: 50),
      receiveTimeout: const Duration(seconds: 150),
    );

    dio = Dio(options);

    /// ✅ Logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  /// 🔹 Generic request method with context
  Future<Response> request(
    BuildContext context, {
    required String path,
    String method = "GET",
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    dio.interceptors.clear(); // reset so we don't add duplicates
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? mToken = await SecureStorage().read(Constants.TOKEN);
          options.headers['authorization'] = mToken!.isNotEmpty ? 'Bearer $mToken' : null;
          options.contentType = Headers.formUrlEncodedContentType;
          return handler.next(options);
        },
        onResponse: (response, handler){
          printFullLog(response.data.toString());
          return handler.next(response);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401) {
            await SecureStorage().clear();

            /// Example: clear navigation and go to login
            Navigator.of(context).pushNamedAndRemoveUntil('/domain', (route) => false);

            /// Or show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Session expired, please login again.",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );

    switch (method.toUpperCase()) {
      case "POST":
        return await dio.post(path, data: data, queryParameters: queryParameters);
      case "PUT":
        return await dio.put(path, data: data, queryParameters: queryParameters);
      case "DELETE":
        return await dio.delete(path, data: data, queryParameters: queryParameters);
      default:
        return await dio.get(path, queryParameters: queryParameters);
    }
  }
}

void printFullLog(String text) {
  const int chunkSize = 800;
  for (var i = 0; i < text.length; i += chunkSize) {
    debugPrint(text.substring(
      i,
      i + chunkSize > text.length ? text.length : i + chunkSize,
    ));
  }
}
