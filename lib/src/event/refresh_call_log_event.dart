import 'package:event_taxi/event_taxi.dart';

class RefreshCallLogEvent extends Event {
  bool isUpdate = false; // ✅ Flag

  RefreshCallLogEvent({required this.isUpdate});
}
