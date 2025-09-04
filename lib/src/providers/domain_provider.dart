import 'package:flutter/cupertino.dart';
import '../Repository/api_calling_repository.dart';
import '../api_response/based_response.dart';

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

  Future<bool> DomainApiCalling(BuildContext context,String mDomainName) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      BasedResponse<String> response = await ApiCallingRepo.GetDomainApiRequest(
        context,
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

  void clearMyText() {
    domainController.clear();
    notifyListeners();
  }
}
