import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Databased/calllog_history.dart';
import '../Providers/theme_provider.dart';
import '../models/appacount_model.dart';
import '../models/telephone_master.dart';
import '../providers/call_logs_provider.dart';
import '../utils/Constants.dart';
import '../utils/secure_storage.dart';
import '../utils/shared_prefs.dart';
import 'action_button.dart';

class DialpadWidget extends StatefulWidget {
  const DialpadWidget(this.CallIsEmpty, {super.key});

  final bool CallIsEmpty;

  @override
  State<DialpadWidget> createState() => _DialpadscreenState();
}

class _DialpadscreenState extends State<DialpadWidget> {
  List<TelephoneMaster> allTelephoneMaster = [];
  EventTaxi eventBus = EventTaxiImpl.singleton();

  var mSipUserNAme = "";
  var mExtentionNumber = "";

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
            padding: const EdgeInsets.all(5),
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
    LayoutProvider mLayoutProvider,
  ) {
    Color? textFieldColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 1);
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    return [
      const SizedBox(height: 8),
      Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            // BoxShadow(
            //   color: Colors.black.withOpacity(0.4), // softer shadow
            //   offset: const Offset(2, 2),
            //   blurRadius: 4,
            //   spreadRadius: 1,
            // ),

            /*Optional */
            // BoxShadow(
            //   color: Colors.black,
            //   offset: const Offset(5.0, 5.0),
            //   blurRadius: 5.0,
            //   spreadRadius: 2.0,
            // ), //BoxShadow
            // BoxShadow(
            //   color: Colors.white,
            //   offset: const Offset(0.0, 0.0),
            //   blurRadius: 0.0,
            //   spreadRadius: 0.0,
            // ), //BoxShado
          ],
        ),
        child: TypeAheadField<CallLogHistory>(
          controller: mCallProvider.phoneNumbCtrl,
          hideOnEmpty: true,
          // debounceDuration: const Duration(milliseconds: 300), // live update
          suggestionsCallback: (search) {
            if (search.isEmpty) {
              return []; // or return full list if you want all suggestions
            }
            return mLayoutProvider.getSuggestions(search);
          },

          itemBuilder: (context, CallLogHistory mCallLogHistory) {
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
                      mCallLogHistory.displName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (mCallLogHistory.remoteExt != null &&
                      mCallLogHistory.remoteExt!.isNotEmpty)
                    TextButton(
                      onPressed:
                          () => {
                            mCallProvider.phoneNumbCtrl.text =
                                mCallLogHistory.remoteExt ?? '',
                          },
                      child: Text(
                        mCallLogHistory.remoteExt ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  SizedBox(width: 10),
                ],
              ),
            );
          },
          onSelected: (CallLogHistory mCallLogHistory) {
            mCallProvider.phoneNumbCtrl.text = mCallLogHistory.remoteExt ?? '';
          },

          // /*Decor SuggestionBox if I clicked on Text field*/
          // decorationBuilder: (context, child) {
          //   return Material(
          //     elevation: 4,
          //     borderRadius: BorderRadius.circular(8),
          //     child: ConstrainedBox(
          //       constraints: BoxConstraints(
          //         maxHeight: 250,
          //       ),
          //       child: Scrollbar(
          //         thumbVisibility: true,
          //         child: SingleChildScrollView(
          //           child: child,
          //         ),
          //       ),
          //     ),
          //   );
          // },

          builder: (context, controller, focusNode) {
            return Material(
              // type: MaterialType.transparency,
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                // textAlign: TextAlign.st,
                style: TextStyle(fontSize: 18, color: textFieldColor),
                decoration: InputDecoration(
                  labelText: "Enter /Search phone number",
                  labelStyle: const TextStyle(color: Colors.white70),
                  floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
                  filled: false,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // default line
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),

                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    child: Material(
                      color: const Color(0xFF1C1B1F), // dark background
                      shape: const CircleBorder(),
                      elevation: 4, // gives the shadow
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          mCallProvider.phoneNumbCtrl.clear();
                          controller.clear();
                        },
                        child: const SizedBox(
                          width: 25,
                          height: 25,
                          child: Center(
                            child: Icon(
                              Icons.clear_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // border: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.grey), // bottom line color
                  // ),
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.grey), // bottom line when not focused
                  // ),
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.blue, width: 2), // line when focused
                  // ),

                  // border: OutlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Colors.blue.withValues(alpha: 0.5),
                  //   ),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Colors.blue.withValues(alpha: 0.5),
                  //   ),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(
                  //     color: Colors.blue.withValues(alpha: 0.5),
                  //   ),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 15),
      // Container(
      //   padding: EdgeInsets.only(right: 15),
      //   alignment: Alignment.centerRight,
      //   child: IconButton(
      //     icon: const Icon(Icons.backspace, size: 15),
      //     onPressed: onBackspacePressed,
      //   ),
      // ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildNumPad(mCallProvider),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
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
                  mCallProvider.clearText();
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

  getDataShow() async {
    mSipUserNAme = (await SecureStorage().read(Constants.SIP_USERNAME))!;
    mExtentionNumber = (await SecureStorage().read(Constants.EXTENSION_NUMBER))!;
  }

  @override
  Widget build(BuildContext context) {
    Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;
    Color? iconColor = Theme.of(context).iconTheme.color;
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final accounts = context.read<AppAccountsModel>();
    final mCallProvider = Provider.of<CallProvider>(context);
    final mLayoutProvider = Provider.of<LayoutProvider>(context);
    // HandleCallState();
    getDataShow();
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
                      SharedPrefs().getValue(Constants.EXTENSION_NUMBER) ?? '',
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
                        showLogoutDialog(context, mCallProvider);
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
                  SharedPrefs().getValue(Constants.SIP_USERNAME) ?? '',
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
            children: _buildDialPad(accounts, mCallProvider, mLayoutProvider),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCallLogBox() async {
    // 1. Close the box if it's open
    if (Hive.isBoxOpen(Constants.TBL_CALLLOG)) {
      await Hive.box(Constants.TBL_CALLLOG).close();
    }

    // 2. Delete the box from disk
    await Hive.deleteBoxFromDisk(Constants.TBL_CALLLOG);

    print('${Constants.TBL_CALLLOG} deleted successfully');
  }

  Future<void> showLogoutDialog(BuildContext context, CallProvider mCallProvider,) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  mLogoutSession(mCallProvider);
                },
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }

  void mLogoutSession(CallProvider mCallProvider) {
    deleteCallLogBox();
    SecureStorage().clear();
    mCallProvider.clearText();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Domainscreen(),
      ),
      ModalRoute.withName("/Login"),
    );
  }
}
