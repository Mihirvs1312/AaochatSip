import '../api_response/based_response.dart';
import '../api_response/login_response.dart';
import '../network/api_client.dart';
import '../utils/app_settings.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ApiCallingRepo {
  static Future<BasedResponse<LoginResponse>> GetmakeApiRequest(
    String email,
    String password,
  ) async {
    String? IDS = await SecureStorage().read(Constants.USER_DOMAIN_ID);

    final response = await ApiClient.instance.request(
      '/tenant/$IDS/auth/login',
      DioMethod.post,
      param: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      BasedResponse<LoginResponse> apiResponse =
          BasedResponse<LoginResponse>.fromJson(
            response.data,
            (data) => LoginResponse.fromJson(data),
          );

      if (apiResponse.status == "success") {
        print('API call successful: ${response.data}');
        // _posts.add(apiResponse.data as LoginResponse);
        print("Mihir:::${apiResponse.data?.token}");

        await SecureStorage().write(
          key: Constants.TOKEN,
          value: apiResponse.data!.token,
        );

        return apiResponse;
      } else {
        print('API call failed: ${apiResponse.message}');
        return BasedResponse<LoginResponse>(
          status: 'error',
          message: apiResponse.message,
        );
      }
    } else {
      print('API call failed: ${response.statusMessage}');
      return BasedResponse<LoginResponse>(
        status: 'error',
        message: response.statusMessage,
      );
    }
  }

  static Future<BasedResponse<String>> GetDomainApiRequest(
    String mDomainName,
  ) async {
    final response = await ApiClient.instance.request(
      AppSettings.API_DOMAIN,
      DioMethod.post,
      param: {'domain': mDomainName},
    );

    if (response.statusCode == 200) {
      BasedResponse<String> apiResponse = BasedResponse<String>.fromJsonString(
        response.data,
        (data) => data.toString(),
      );

      if (apiResponse.status == "success") {
        await SecureStorage().write(
          key: Constants.USER_DOMAIN_ID,
          value: apiResponse.data!,
        );

        return apiResponse;
      } else {
        print('API call failed: ${apiResponse.message}');
        return BasedResponse<String>(
          status: 'error',
          message: apiResponse.message,
        );
      }
    } else {
      print('API call failed: ${response.statusMessage}');
      return BasedResponse<String>(
        status: 'error',
        message: response.statusMessage,
      );
    }
  }
}
