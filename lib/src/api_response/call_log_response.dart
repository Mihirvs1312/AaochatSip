import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/app_settings.dart';

@JsonSerializable()
class CallLogResponse {
  final String calldate;
  final String clid;
  final String src;
  final String dst;
  final String dcontext;
  final String channel;
  final String dstchannel;
  final String lastapp;
  final String lastdata;
  final int duration;
  final int billsec;
  final String disposition;
  final int amaflags;
  final String accountcode;
  final String uniqueid;
  final String userfield;
  final String did;
  final String recordingfile;
  final String cnum;
  final String cnam;
  final String outboundCnum;
  final String outboundCnam;
  final String dstCnam;
  final String linkedid;
  final String peeraccount;
  final int sequence;


  CallLogResponse({
    required this.calldate,
    required this.clid,
    required this.src,
    required this.dst,
    required this.dcontext,
    required this.channel,
    required this.dstchannel,
    required this.lastapp,
    required this.lastdata,
    required this.duration,
    required this.billsec,
    required this.disposition,
    required this.amaflags,
    required this.accountcode,
    required this.uniqueid,
    required this.userfield,
    required this.did,
    required this.recordingfile,
    required this.cnum,
    required this.cnam,
    required this.outboundCnum,
    required this.outboundCnam,
    required this.dstCnam,
    required this.linkedid,
    required this.peeraccount,
    required this.sequence,
  });


  factory CallLogResponse.fromJson(Map<String, dynamic> json) {
    return CallLogResponse(
      calldate: json["calldate"] ?? "",
      clid: json["clid"] ?? "",
      src: json["src"] ?? "",
      dst: json["dst"] ?? "",
      dcontext: json["dcontext"] ?? "",
      channel: json["channel"] ?? "",
      dstchannel: json["dstchannel"] ?? "",
      lastapp: json["lastapp"] ?? "",
      lastdata: json["lastdata"] ?? "",
      duration: json["duration"] ?? 0,
      billsec: json["billsec"] ?? 0,
      disposition: json["disposition"] ?? "",
      amaflags: json["amaflags"] ?? 0,
      accountcode: json["accountcode"] ?? "",
      uniqueid: json["uniqueid"] ?? "",
      userfield: json["userfield"] ?? "",
      did: json["did"] ?? "",
      recordingfile: json["recordingfile"] ?? "",
      cnum: json["cnum"] ?? "",
      cnam: json["cnam"] ?? "",
      outboundCnum: json["outbound_cnum"] ?? "",
      outboundCnam: json["outbound_cnam"] ?? "",
      dstCnam: json["dst_cnam"] ?? "",
      linkedid: json["linkedid"] ?? "",
      peeraccount: json["peeraccount"] ?? "",
      sequence: json["sequence"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "calldate": calldate,
      "clid": clid,
      "src": src,
      "dst": dst,
      "dcontext": dcontext,
      "channel": channel,
      "dstchannel": dstchannel,
      "lastapp": lastapp,
      "lastdata": lastdata,
      "duration": duration,
      "billsec": billsec,
      "disposition": disposition,
      "amaflags": amaflags,
      "accountcode": accountcode,
      "uniqueid": uniqueid,
      "userfield": userfield,
      "did": did,
      "recordingfile": recordingfile,
      "cnum": cnum,
      "cnam": cnam,
      "outbound_cnum": outboundCnum,
      "outbound_cnam": outboundCnam,
      "dst_cnam": dstCnam,
      "linkedid": linkedid,
      "peeraccount": peeraccount,
      "sequence": sequence,
    };
  }

  String getRecordingFile() {
    DateTime date = DateFormat('MM/dd/yyyy HH:mm:ss a').parse(calldate);
    String url = AppSettings.baseUrlSip +
        "/recording/${date.year}/${date.month.toString().padLeft(2, '0')}/${date.toUtc().day.toString().padLeft(2, '0')}/${recordingfile}";
    return url;
  }

}
