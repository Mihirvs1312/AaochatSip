import 'package:dio/dio.dart';

import 'ApiClient.dart';

class APIService {
  final Dio _dio = ApiClient.dio;

  /*TODO: Option:1-> This Method is Direct Implementation*/
  Future<Response> getPost(int id) async {
    return await _dio.get('/users/all-contact-details/$id');
  }

  Future<Response> createPost(Map<String, dynamic> data) async {
    return await _dio.post('/users/all-contact-details', data: data);
  }

  /*TODO: Option:2-> This Method is SingleTon Implementation*/
  Future<void> makeApiRequest(String email, String password) async {
    try {
      final response = await ApiClient.instance.request(
        '/posts',
        DioMethod.post,
        param: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        print('API call successful: ${response.data}');
      } else {
        print('API call failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Network error occurred: $e');
    }
  }
}
