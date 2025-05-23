import 'dart:convert';

class TelephoneMaster {
  String? ext_no;
  String? mob_no;
  String? home_no;
  String? user_name;

  // create a constructor
  TelephoneMaster({this.ext_no, this.mob_no, this.home_no, this.user_name});

  // create a factory method
  factory TelephoneMaster.fromMap(Map<String, dynamic> json) {
    return TelephoneMaster(
      ext_no: json['ext_no'],
      mob_no: json['mob_no'],
      home_no: json['home_no'],
      user_name: json['user_name'],
    );
  }

  // create a toJson method
  Map<String, dynamic> toMap() {
    return {
      'ext_no': ext_no,
      'mob_no': mob_no,
      'home_no': home_no,
      'user_name': user_name,
    };
  }

  // create a toJson method
  String toJson() {
    return jsonEncode(toMap());
  }
}
