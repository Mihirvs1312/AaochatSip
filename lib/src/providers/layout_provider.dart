import 'package:audioplayers/audioplayers.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';

import '../models/RefreshCallLogEvent.dart';
import '../models/call_model.dart';

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
