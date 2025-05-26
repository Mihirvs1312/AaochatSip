import 'dart:async';

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
  const CallScreenWidget(this.popUpMode, {super.key});

  static const routeName = "/addCall";
  final bool popUpMode;

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
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Scaffold(
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // !calls.isEmpty
                //     ? IncommingCallScreen()
                // IncommingCallScreen()
                Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: /*IndexedStack(children: [*/ DialpadWidget(
                        widget.popUpMode,
                      ) /*])*/,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
