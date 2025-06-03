import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import '../../main.dart';
import '../models/appacount_model.dart';
import '../models/call_model.dart';
import '../utils/Constants.dart';
import '../utils/secure_storage.dart';

class CallProvider extends ChangeNotifier {
  final _phoneNumbCtrl = TextEditingController();

  TextEditingController get phoneNumbCtrl => _phoneNumbCtrl;
  String? _errText;
  String? _sip_username;
  String? _ExtentionNumber;

  String? get errorText => _errText;

  String? get mSipUserNAme => _sip_username;

  String? get mExtentionNumber => _ExtentionNumber;

  void AddData(BuildContext context, AccountModel _account) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_account == null) {
      _errText = "No account data passed to this screen.";
      // notifyListeners();
      // return;
    }

    // _account = args;
    _account.sipServer = '192.168.75.240';
    _account.sipExtension = '1284';
    _account.sipPassword = '1284Deepf00ds';
    _account.expireTime = 350;
    _account.transport = SipTransport.udp;
    _account.rewriteContactIp = true;
    _account.ringTonePath = MyApp.getRingtonePath();

    Future<void> action = context.read<AppAccountsModel>().addAccount(_account);

    action
        .then((_) {
          _errText = null;
        })
        .catchError((error) {
          _errText = error.toString();
        });

    notifyListeners();
  }

  void mInvite(BuildContext context, bool withVideo, AccountsModel accounts) {
    final accounts = context.read<AppAccountsModel>();
    if (accounts.selAccountId == null) {
      _errText = "Account not selected";
      return;
    }

    debugPrint('AccountId: ${accounts.selAccountId}');

    //Prepare destination details
    CallDestination dest = CallDestination(
      _phoneNumbCtrl.text,
      accounts.selAccountId!,
      withVideo,
    );

    context
        .read<AppCallsModel>()
        .invite(dest)
        .then((_) => _errText = "")
        .catchError((error) {
          _errText = error.toString();
        });

    notifyListeners();
  }

  Future<void> DataDisplay() async {
    _sip_username = await SecureStorage().read(Constants.SIP_USERNAME);
    _ExtentionNumber = await SecureStorage().read(Constants.EXTENSION_NUMBER);
  }

  void clearText() {
    _phoneNumbCtrl.clear();
  }
}
