import 'extension_model.dart';

class User {
  String id;
  String userName;
  String email;
  String fullName;
  String phoneNumber;
  String role;
  String status;
  String? jira;
  DateTime createdAt;
  DateTime updatedAt;
  List<Extension> extensions;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.jira,
    required this.createdAt,
    required this.updatedAt,
    required this.extensions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      userName: json['user_name'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      status: json['status'],
      jira: json['jira'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      extensions: (json['extensions'] as List<dynamic>?)
          ?.map((e) => Extension.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_name': userName,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'status': status,
      'jira': jira,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'extensions': extensions.map((e) => e.toJson()).toList(),
    };
  }
}
