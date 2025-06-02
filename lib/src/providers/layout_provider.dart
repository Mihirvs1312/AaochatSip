import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:uuid/uuid.dart';

import '../models/RefreshCallLogEvent.dart';
import '../utils/Constants.dart';

class LayoutProvider extends ChangeNotifier {
  String _currentScreen = 'dialpad';

  String get currentScreen => _currentScreen;

  String sideScreen = 'call-logs';
  String callId = '';
  EventTaxi eventBus = EventTaxiImpl.singleton();

  Map<String, String> allTelephoneMaster = <String, String>{};

  String _Callstatus = '';

  String get status => _Callstatus;

  final player = AudioPlayer();

  final Box<CallLogHistory> _box = Hive.box<CallLogHistory>(
    Constants.TBL_CALLLOG,
  );
  DateFormat format = DateFormat("MMM dd yyyy, hh:mm:ss a");

  List<CallLogHistory> get mCallLogHistory =>
      _box.values.toList().reversed.toList();

  Future<void> UpdateCallLog(CallLogHistory callLog) async {
    final box = Hive.box<CallLogHistory>(Constants.TBL_CALLLOG);
    try {
      // Parse to DateTime
      DateTime parsedDate = format.parse(callLog.madeAtDate!);
      // Use millisecondsSinceEpoch as key
      String key = (parsedDate.millisecondsSinceEpoch.toString());
      // Save to Hive (add or update)
      await box.put(key, callLog);
      notifyListeners();

      print('Record added or updated at $key');
    } catch (e) {
      print('Failed to parse date or save record: $e');
    }
  }

  Future<void> Updateduration(String mDuration) async {
    if (_box.isNotEmpty) {
      final lastRecord = _box.values.last;
      DateTime parsedDate = format.parse(lastRecord.madeAtDate!);
      String key = (parsedDate.millisecondsSinceEpoch.toString());
      lastRecord.duration = mDuration;
      _box.put(key, lastRecord);
      notifyListeners();
    }
  }

  List<CallLogHistory> getSuggestions(String pattern) {
    return _box.values
        .where((log) => log.displName!.contains(pattern))
        .toList();
  }

  Future<void> deleteCallLog(CallLogHistory cdr) async {
    final keyToDelete = _box.keys.firstWhere(
      (key) => _box.get(key)?.madeAtDate == cdr.madeAtDate,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      _box.delete(keyToDelete);
      print("Record with id ${cdr.madeAtDate} deleted.");
    } else {
      print("Record not found.");
    }
    notifyListeners();
  }

  playRingtone() async {
    player.setVolume(1);
    await player.play(AssetSource('ringtone.mp3'));
  }

  stopRingtone() async {
    await player.stop();
  }

  // getCallDestinationName(CallLog? callLog) {
  //   String response = '${callLog?.dst}';
  //   if (callLog?.outbound_cnam != null && callLog!.outbound_cnam.isNotEmpty) {
  //     response += ' - ${callLog.outbound_cnam}';
  //   } else if (allTelephoneMaster[callLog?.dst ?? ''] != null) {
  //     response += ' - ${allTelephoneMaster[callLog?.dst ?? '']}';
  //   }
  //
  //   return response;
  // }

  /*Todo Api Calling Pending*/
  // getAllTelephoneMaster() async {
  //   var response = await TeamlocusRepository.getAllTelephoneMaster();
  //   if (response.status == 'ok') {
  //     for (var item in response.response!) {
  //       if (item.ext_no != null && item.ext_no!.isNotEmpty) {
  //         allTelephoneMaster[item.ext_no!] = item.user_name ?? '';
  //       }
  //     }
  //   }
  // }

  void UpdateCallToLogList(BuildContext context, CdrsModel calls,AppCallsModel callsModel) {
    if (!calls.isEmpty) {
      final callLog = CallLogHistory(
        myCallId: calls[0].myCallId,
        displName: calls[0].displName,
        remoteExt: calls[0].remoteExt,
        accUri: calls[0].accUri,
        duration: callsModel[0].durationStr,
        hasVideo: calls[0].hasVideo,
        incoming: calls[0].incoming,
        connected: calls[0].connected,
        statusCode: calls[0].statusCode,
        madeAtDate: calls[0].madeAtDate,
      );
      UpdateCallLog(callLog);
      log("Call_Update_Log: ${callLog.toString()}");
    }
  }

  goToCallScreen() {
    _currentScreen = 'callscreen';
    notifyListeners();
  }


  clearCall(bool mIsUpdate) {
    eventBus.fire(RefreshCallLogEvent(isUpdate: mIsUpdate));
  }

  goToDialPad() {
    _currentScreen = 'dialpad';
    notifyListeners();
  }

  goToCreateSupportTicket(String? callId) {
    this.callId = callId ?? '';
    sideScreen = 'create-support-ticket';
    notifyListeners();
  }

  goToCallLogs() {
    sideScreen = 'call-logs';
    callId = '';
    notifyListeners();
  }

  String getFormattedCallStatus(CallLogHistory cdr) {
    var mStatus = "";
    if (cdr.connected!) {
      mStatus = 'ANSWERED';
      return 'ANSWERED';
    } else if (cdr.incoming! && !cdr.connected!) {
      mStatus = 'MISSED CALL';
      return 'MISSED CALL';
    } else if (!cdr.connected!) {
      mStatus = 'NO ANSWER';
      return 'NO ANSWER';
    }
    return mStatus.toUpperCase();
  }

  Color getCallLogColor(CallLogHistory cdr) {
    if (cdr.connected!) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String convertDateFormat(String dateString) {
    try {
      String currentFormat1 = "MMM dd yyyy, hh:mm:ss a";
      String desiredFormat1 = "MMM dd yyyy, hh:mm:ss a";

      // Step 1: Parse the original date string into a DateTime object
      DateFormat inputFormat = DateFormat(currentFormat1);
      DateTime dateTime = inputFormat.parse(dateString);

      // Step 2: Format the DateTime object into the new desired date string format
      DateFormat outputFormat = DateFormat(desiredFormat1);
      String formattedDate = outputFormat.format(dateTime);

      return formattedDate;
    } catch (e) {
      print('Error during date format conversion: $e');
      // print(
      //   'Input String: "$dateString", Current Format: "$currentFormat1", Desired Format: "$desiredFormat1"',
      // );
      // Return original string or a default error string if conversion fails
      return dateString; // Or throw e; or return 'Invalid Date';
    }
  }
}
