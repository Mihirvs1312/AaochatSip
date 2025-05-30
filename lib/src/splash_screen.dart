import 'dart:async';

import 'package:callingproject/src/pages/call_screen.dart';
import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/pages/incomming_call_screen.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  static const routeName = "/splash";

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      String? value = await SecureStorage().read(Constants.IS_LOGGEDIN);
      bool boolvalue = value == 'true';
      if (boolvalue) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CallScreenWidget()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Domainscreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('assets/aao_logo.png',height: 250,width: 250,)));
  }
}
