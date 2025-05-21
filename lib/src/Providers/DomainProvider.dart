import 'package:flutter/cupertino.dart';

import '../ApiResponse/BasedResponse.dart';
import '../Repository/ApiCallingRepo.dart';

class DomainProvider extends ChangeNotifier {
  bool _loading = false;
  late String _error;

  String get error => _error;

  bool get isLoading => _loading;

  var ValidatorDomainMsg;
  final domainController = TextEditingController();

  bool validate() {
    bool isValid = true;

    if (domainController.text.trim().isEmpty) {
      ValidatorDomainMsg = 'Domain is required';
      isValid = false;
    } else {
      ValidatorDomainMsg = null;
    }

    notifyListeners();
    return isValid;
  }

  Future<bool> DomainApiCalling(String mDomainName) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      BasedResponse<String> response = await ApiCallingRepo.GetDomainApiRequest(
        mDomainName,
      );
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
}
