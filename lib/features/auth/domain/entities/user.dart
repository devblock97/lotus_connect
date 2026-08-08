import 'package:flutter/foundation.dart';

/// Pure Dart entity representing a registered/authenticated User.
@immutable
class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.friendshipStatus,
    this.friendshipSenderId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      friendshipStatus: json['friendshipStatus'] as String?,
      friendshipSenderId: json['friendshipSenderId'] as String?,
    );
  }

  final String id;
  final String username;
  final String? fullName;
  final String email;
  final String? friendshipStatus;
  final String? friendshipSenderId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (fullName != null) 'fullName': fullName,
      'email': email,
      if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
      if (friendshipSenderId != null) 'friendshipSenderId': friendshipSenderId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
