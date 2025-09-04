import 'dart:async';
import 'dart:io';

import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:window_manager/window_manager.dart';

import '../models/call_model.dart';
import '../providers/call_logs_provider.dart';
import '../widget/dialpad_widget.dart';
import '../widget/loglist_widget.dart';
import 'incomming_call_screen.dart';

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget({super.key});

  static const routeName = "/addCall";

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget>
    with WindowListener {
  AccountModel _account = AccountModel();
  double _windowWidth = 1150;
  var _selectedPageIndex = 0;
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
        if (provider.errorText != null)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(provider.errorText!)));
      } on Exception catch (e) {
        print(e.toString());
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   var callProvider = Provider.of<CallProvider>(context, listen: false);
    //   callProvider.AddData(context, _account);
    //
    //   try {
    //     if (callProvider.errorText != null) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(callProvider.errorText!)),
    //       );
    //     }
    //   } on Exception catch (e) {
    //     print(e.toString());
    //   }
    // });
  }

  /*TODO This is Working Build Method*/
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
    } else {
      provider.goToDialPad();
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
                Consumer<LayoutProvider>(
                  builder: (context, provider, child) {
                    return Container(
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
                    );
                  },
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


  // @override
  // Widget build(BuildContext context) {
  //   final provider = Provider.of<LayoutProvider>(context, listen: false);
  //   return Scaffold(
  //     appBar: !Platform.isWindows && !Platform.isMacOS
  //         ? AppBar(
  //       title: Text('Teamlocus SIP'),
  //       actions: [
  //         SizedBox(width: 10),
  //       ],
  //     )
  //         : null,
  //     body: getBody(provider),
  //     bottomNavigationBar: MediaQuery
  //         .sizeOf(context)
  //         .width > _windowWidth
  //         ? null
  //         : BottomNavigationBar(
  //       currentIndex: _selectedPageIndex,
  //       onTap: _onTabTapped(0, provider),
  //       items: [
  //         BottomNavigationBarItem(
  //             icon: Icon(Icons.dialpad_outlined), label: 'Phone'),
  //         BottomNavigationBarItem(
  //             icon: Icon(Icons.call), label: 'Call Logs'),
  //       ],
  //     ),
  //     bottomSheet: _networkLostIndicator(),
  //   );
  // }

  Widget? _networkLostIndicator() {
    if (context
        .watch<NetworkModel>()
        .networkLost) {
      return Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          color: Colors.red,
          child: const Text("Internet connection lost",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center));
    }
    return null;
  }

  _onTabTapped(int index, LayoutProvider provider) {
    _selectedPageIndex = index;
    if (index == 0) {
      provider.goToDialPad();
    }
  }

  getBody(LayoutProvider provider) {
    final calls = context.watch<AppCallsModel>();
    if (!calls.isEmpty) {
      try {
        provider.goToCallScreen();
      } catch (e) {
        print('Error in callStateChanged: $e');
      }
    } else {
      provider.goToDialPad();
    }
    if (MediaQuery
        .of(context)
        .size
        .width > _windowWidth) {
      return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          return true;
        },
        child: SizeChangedLayoutNotifier(
          child: Scaffold(
            body: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Row(
                children: [
                  Consumer<LayoutProvider>(
                    builder: (context, provider, child) {
                      return Container(
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
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .surface,
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
}
