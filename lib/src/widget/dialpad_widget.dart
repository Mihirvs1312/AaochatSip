import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import '../models/appacount_model.dart';
import '../models/telephone_master.dart';
import '../providers/call_logs_provider.dart';
import 'action_button.dart';

enum CdrAction { delete, deleteAll }

class DialpadWidget extends StatefulWidget {
  const DialpadWidget(this.popUpMode, {super.key});

  static const routeName = "/addCall";
  final bool popUpMode;

  @override
  State<DialpadWidget> createState() => _DialpadscreenState();
}

class _DialpadscreenState extends State<DialpadWidget> {
  List<TelephoneMaster> allTelephoneMaster = [];
  String extensionNo = '';

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
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      TypeAheadField<TelephoneMaster>(
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
      SizedBox(height: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildNumPad(mCallProvider),
      ),

      Consumer<CallProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ActionButton(
                  icon: Icons.videocam,
                  onPressed: () => provider.mInvite(context, true, accounts),
                ),
                ActionButton(
                  icon: Icons.dialer_sip,
                  fillColor: Colors.green,
                  onPressed: () {
                    provider.mInvite(context, false, accounts);

                    if (provider.errorText != "") {
                      if (widget.popUpMode) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.errorText!)),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;
    Color? iconColor = Theme.of(context).iconTheme.color;
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final accounts = context.read<AppAccountsModel>();
    final mCallProvider = Provider.of<CallProvider>(context);

    return Material(
      type: MaterialType.transparency,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${extensionNo}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {},
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
}
