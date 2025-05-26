class Extension {
  String id;
  String userId;
  String sipServerId;
  String extensionNumber;
  String sipUsername;
  String sipPassword;
  DateTime createdAt;
  DateTime updatedAt;

  Extension({
    required this.id,
    required this.userId,
    required this.sipServerId,
    required this.extensionNumber,
    required this.sipUsername,
    required this.sipPassword,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Extension.fromJson(Map<String, dynamic> json) {
    return Extension(
      id: json['_id'],
      userId: json['user_id'],
      sipServerId: json['sip_server_id'],
      extensionNumber: json['extension_number'],
      sipUsername: json['sip_username'],
      sipPassword: json['sip_password'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'sip_server_id': sipServerId,
      'extension_number': extensionNumber,
      'sip_username': sipUsername,
      'sip_password': sipPassword,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}