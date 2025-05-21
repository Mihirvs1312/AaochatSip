import 'package:callingproject/src/ApiResponse/BasedResponse.dart';
import 'package:callingproject/src/Repository/ApiCallingRepo.dart';
import 'package:flutter/cupertino.dart';
import '../ApiResponse/LoginResponse.dart';

class LoginProvider extends ChangeNotifier {
  bool _loading = false;
  late String _error;

  String get error => _error;

  bool get isLoading => _loading;

  String? ErrorMessage;
  final mEmailController = TextEditingController();
  final mPasswordController = TextEditingController();

  Future<bool> ApiCalling(String email, String password) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      BasedResponse<LoginResponse> response =
          await ApiCallingRepo.GetmakeApiRequest(email, password);
      if (response.status == "success") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool validate() {
    bool isValid = true;

    if (mEmailController.text.trim().isEmpty) {
      ErrorMessage = 'Email/Username is required';
      isValid = false;
    } else if (!mEmailController.text.trim().contains('@')) {
      ErrorMessage = 'Please enter a valid email';
      isValid = false;
    } else if (mPasswordController.text.trim().isEmpty) {
      ErrorMessage = 'Password is required';
      isValid = false;
    } else {
      ErrorMessage = null;
    }

    notifyListeners();
    return isValid;
  }
}
