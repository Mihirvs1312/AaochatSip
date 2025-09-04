import 'extension_model.dart';

class User {
  String? id;
  String? userName;
  String? email;
  String? fullName;
  String? phoneNumber;
  String? role;
  String? status;
  String? jira;
  String? createdAt;
  String? updatedAt;
  List<Extension>? extensions;

  User({
    this.id,
    this.userName,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.status,
    this.jira,
    this.createdAt,
    this.updatedAt,
    this.extensions,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    userName: json["user_name"],
    email: json["email"],
    fullName: json["full_name"],
    phoneNumber: json["phone_number"],
    role: json["role"],
    status: json["status"],
    jira: json["jira"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    extensions: json["extensions"] == null
        ? []
        : List<Extension>.from(
        json["extensions"].map((x) => Extension.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user_name": userName,
    "email": email,
    "full_name": fullName,
    "phone_number": phoneNumber,
    "role": role,
    "status": status,
    "jira": jira,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "extensions":
    extensions == null ? [] : extensions!.map((x) => x.toJson()).toList(),
  };
}
