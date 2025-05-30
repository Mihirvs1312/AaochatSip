import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/pages/login_screen.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Providers/theme_provider.dart';
import '../models/appacount_model.dart';
import '../models/call_model.dart';
import '../models/telephone_master.dart';
import '../providers/call_logs_provider.dart';
import '../utils/secure_storage.dart';
import 'action_button.dart';

enum CdrAction { delete, deleteAll }

class DialpadWidget extends StatefulWidget {
  const DialpadWidget(this.CallIsEmpty, {super.key});

  final bool CallIsEmpty;

  @override
  State<DialpadWidget> createState() => _DialpadscreenState();
}

class _DialpadscreenState extends State<DialpadWidget> {
  List<TelephoneMaster> allTelephoneMaster = [];
  EventTaxi eventBus = EventTaxiImpl.singleton();

  List<TelephoneMaster> filterTelephoneMaster(String search) {
    if (search.isEmpty) {
      return [];
    }
    return allTelephoneMaster
        .where(
          (telephoneMaster) =>
              (telephoneMaster.user_name ?? '').toLowerCase().contains(
                search.toLowerCase(),
              ) ||
              (telephoneMaster.ext_no ?? '').toLowerCase().contains(
                search.toLowerCase(),
              ) ||
              (telephoneMaster.home_no ?? '').toLowerCase().contains(
                search.toLowerCase(),
              ) ||
              (telephoneMaster.mob_no ?? '').toLowerCase().contains(
                search.toLowerCase(),
              ),
        )
        .toList();
  }

  void _handleNum(String number, CallProvider mCallProvider) {
    setState(() {
      mCallProvider.phoneNumbCtrl.text += number;
    });
  }

  List<Widget> _buildNumPad(CallProvider mCallProvider) {
    final labels = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'},
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'},
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'},
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''},
      ],
    ];

    return labels
        .map(
          (row) => Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  row
                      .map(
                        (label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed:
                              () => _handleNum(label.keys.first, mCallProvider),
                          number: true,
                        ),
                      )
                      .toList(),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildDialPad(
    AccountsModel accounts,
    CallProvider mCallProvider,
  ) {
    Color? textFieldColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withOpacity(1);
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    return [
      const SizedBox(height: 8),
      Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(5.0),
          boxShadow: [
            // BoxShadow(color: Colors.black, spreadRadius: 5, blurRadius: 3),
            BoxShadow(
              color: Colors.black,
              offset: const Offset(5.0, 5.0),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ), //BoxShadow
            BoxShadow(
              color: Colors.white,
              offset: const Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ), //BoxShado
          ],
        ),
        child: TypeAheadField<TelephoneMaster>(
          controller: mCallProvider.phoneNumbCtrl,
          hideOnEmpty: true,
          suggestionsCallback: (search) => filterTelephoneMaster(search),
          itemBuilder: (context, telephoneMaster) {
            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[200]!,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      telephoneMaster.user_name ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (telephoneMaster.ext_no != null &&
                      telephoneMaster.ext_no!.isNotEmpty)
                    TextButton(
                      onPressed:
                          () => {
                            mCallProvider.phoneNumbCtrl.text =
                                telephoneMaster.ext_no ?? '',
                          },
                      child: Text(telephoneMaster.ext_no ?? ''),
                    ),
                  SizedBox(width: 10),
                ],
              ),
            );
          },
          onSelected: (telephoneMaster) {
            mCallProvider.phoneNumbCtrl.text = telephoneMaster.ext_no ?? '';
          },
          builder: (context, controller, focusNode) {
            return Material(
              type: MaterialType.transparency,
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: textFieldColor),
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textFieldFill,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: controller,
                focusNode: focusNode,
              ),
            );
          },
        ),
      ),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.backspace, size: 15),
          onPressed: onBackspacePressed,
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildNumPad(mCallProvider),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Visibility(
              visible: false,
              child: ActionButton(
                icon: Icons.videocam,
                onPressed: () => mCallProvider.mInvite(context, true, accounts),
              ),
            ),

            // GestureDetector(
            //   onTapDown: (_) {
            //     setState(() {
            //       _isElevated = true;
            //     });
            //   },
            //   onTapUp: (_) {
            //     setState(() {
            //       _isElevated = false;
            //     });
            //   },
            //   onTapCancel: () {
            //     setState(() {
            //       _isElevated = false;
            //     });
            //   },
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            //     decoration: BoxDecoration(
            //       color: Color(0xFF171717),
            //       // shape: BoxShape.circle, // Makes it round
            //       borderRadius: BorderRadius.circular(12),
            //       boxShadow:
            //           _isElevated
            //               ? [
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.15),
            //                   offset: Offset(-2, -2),
            //                   blurRadius: 6,
            //                 ),
            //                 BoxShadow(
            //                   color: Colors.white.withOpacity(0.7),
            //                   offset: Offset(2, 2),
            //                   blurRadius: 6,
            //                 ),
            //               ]
            //               : [
            //                 BoxShadow(
            //                   color: Colors.white.withOpacity(
            //                     0.1,
            //                   ), // Top-left shadow
            //                   offset: Offset(-6, -6),
            //                   blurRadius: 16,
            //                 ),
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.4),
            //                   // Bottom-right shadow
            //                   offset: Offset(6.0, 6.0),
            //                   blurRadius: 16,
            //                 ),
            //               ],
            //     ),
            //     child: Text(
            //       "Click Me",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            ActionButton(
              icon: Icons.dialer_sip,
              fillColor: Colors.green,
              onPressed: () {
                mCallProvider.mInvite(context, false, accounts);
                if (mCallProvider.errorText != "") {
                  mCallProvider.phoneNumbCtrl.text = '';
                  // if (widget.popUpMode) {
                  //   Navigator.of(context).pop();
                  // }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mCallProvider.errorText!)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ];
  }

  void onBackspacePressed() {
    final mCallProvider = Provider.of<CallProvider>(context, listen: false);
    if (mCallProvider.phoneNumbCtrl.text.isNotEmpty) {
      mCallProvider.phoneNumbCtrl.text = mCallProvider.phoneNumbCtrl.text
          .substring(0, mCallProvider.phoneNumbCtrl.text.length - 1);
    }
  }

  @override
  void initState() {
    super.initState();
    // try {
    //   final mprovider = Provider.of<CallProvider>(context, listen: false);
    //   mprovider.DataDisplay();
    // } catch (e) {
    //   print(e);
    // }
    // eventBus.registerTo<PlaceCallEvent>(false).listen((event) {
    //   _textController.text = event.phoneNumber;
    //   if (getx.Get.find<LayoutController>().currentCall == null) {
    //     _handleCall(context, true);
    //   } else {
    //     PageExtender.showErrorSnackbar("One call already in progress");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;
    Color? iconColor = Theme.of(context).iconTheme.color;
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final accounts = context.read<AppAccountsModel>();
    final mCallProvider = Provider.of<CallProvider>(context);
    // HandleCallState();
    final calls = context.watch<AppCallsModel>();

    return Material(
      type: MaterialType.transparency,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // calls.connected
                //     ? Icon(
                //   Icons.connected_tv_rounded,
                //   color: Colors.green,
                // )
                //     : Icon(
                //   Icons.connected_tv_rounded,
                //   color: Colors.red,
                // ),
                Consumer<CallProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.mExtentionNumber}',
                      style: TextStyle(
                        // color: Theme.of(context).colorScheme.primary,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) async {
                    switch (value) {
                      case 'logout':
                        deleteCallLogBox();
                        SecureStorage().clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Domainscreen(),
                          ),
                          ModalRoute.withName("/Login"),
                        );
                        break;
                      case 'theme':
                        final themeProvider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ); // get the provider, listen false is necessary cause is in a function

                        setState(() {
                          isDarkTheme = !isDarkTheme;
                        }); // change the variable

                        isDarkTheme // call the functions
                            ? themeProvider.setDarkmode()
                            : themeProvider.setLightMode();
                        break;
                      default:
                        break;
                    }
                  },
                  icon: Icon(Icons.menu),
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.logout, color: iconColor),
                              SizedBox(width: 12),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Consumer<CallProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.mSipUserNAme ?? '',
                  style: TextStyle(fontSize: 18, color: textColor),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildDialPad(accounts, mCallProvider),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCallLogBox() async {
    const boxName = 'call_log';

    // 1. Close the box if it's open
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }

    // 2. Delete the box from disk
    await Hive.deleteBoxFromDisk(boxName);

    print('$boxName deleted successfully');
  }
}
