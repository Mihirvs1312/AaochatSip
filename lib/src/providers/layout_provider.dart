import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:uuid/uuid.dart';

import '../models/RefreshCallLogEvent.dart';

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

  final Box<CallLogHistory> _box = Hive.box<CallLogHistory>('call_log');

  List<CallLogHistory> get mCallLogHistory => _box.values.toList();

  Future<void> UpdateCallLog(CallLogHistory callLog) async {
    // final item = _box.getAt(0);
    // callLog.id = item?.id.toString();
    _box.put(callLog.madeAtDate, callLog);
    print('Record updated');
    notifyListeners();
  }

  void Updateduration(String mDuration) {
    if (_box.isNotEmpty) {
      final lastRecord = _box.values.last;
      lastRecord.duration = mDuration;
      _box.put(lastRecord.madeAtDate, lastRecord);
      notifyListeners();
    }
  }

  Future<void> deleteCallLog(int index) async {
    _box.deleteAt(index);
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

  void UpdateCallToLogList(BuildContext context, CdrsModel calls) {
    if (!calls.isEmpty) {
      final callLog = CallLogHistory(
        myCallId: calls[0].myCallId,
        displName: calls[0].displName,
        remoteExt: calls[0].remoteExt,
        accUri: calls[0].accUri,
        duration: calls[0].duration,
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

  clearCall() {
    eventBus.fire(RefreshCallLogEvent());
    notifyListeners();
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
}
