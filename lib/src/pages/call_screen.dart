import 'dart:async';

import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/video.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';
import '../models/appacount_model.dart';
import '../models/call_model.dart';
import '../providers/call_logs_provider.dart';
import '../widget/dialpad_widget.dart';
import 'incomming_call_screen.dart';
import '../widget/loglist_widget.dart';

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget({super.key});

  static const routeName = "/addCall";

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget>
    with WindowListener {
  AccountModel _account = AccountModel();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _account =
        (ModalRoute.of(context)?.settings.arguments as AccountModel?) ??
        AccountModel();
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    Future.microtask(() {
      final provider = Provider.of<CallProvider>(context, listen: false);
      provider.AddData(context, _account);

      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorText!)));
      } on Exception catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final calls = context.watch<AppCallsModel>();
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    if (!calls.isEmpty) {
      try {
        provider.goToCallScreen();
      } catch (e) {
        print('Error in callStateChanged: $e');
      }
    }

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: IndexedStack(
                    index: provider.currentScreen == 'dialpad' ? 0 : 1,
                    children: [
                      DialpadWidget(calls.isEmpty),
                      !calls.isEmpty && provider.currentScreen != 'dialpad'
                          ? IncommingCallScreen()
                          : SizedBox(),
                      // : SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: LogListScreen(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
