import 'package:hive/hive.dart';

part 'calllog_history.g.dart';

@HiveType(typeId: 1)
class CallLogHistory extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final int? myCallId;

  @HiveField(2)
  String? displName;

  @HiveField(3)
  String? remoteExt;

  @HiveField(4)
  String? accUri;

  @HiveField(5)
  String? duration;

  @HiveField(6)
  bool? hasVideo;

  @HiveField(7)
  bool? incoming;

  @HiveField(8)
  bool? connected;

  @HiveField(9)
  int? statusCode;

  @HiveField(10)
  String? madeAtDate;

  CallLogHistory({
    this.id,
    this.myCallId,
    this.displName,
    this.remoteExt,
    this.accUri,
    this.duration,
    this.hasVideo,
    this.incoming,
    this.connected,
    this.statusCode,
    this.madeAtDate,
  });
}
