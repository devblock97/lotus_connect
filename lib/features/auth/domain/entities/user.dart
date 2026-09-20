import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Pure Dart entity representing a registered/authenticated User.
@immutable
class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.friendshipStatus,
    this.friendshipSenderId,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      friendshipStatus: json['friendshipStatus'] as String?,
      friendshipSenderId: json['friendshipSenderId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String username;
  final String? fullName;
  final String email;
  final String? friendshipStatus;
  final String? friendshipSenderId;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (fullName != null) 'fullName': fullName,
      'email': email,
      if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
      if (friendshipSenderId != null) 'friendshipSenderId': friendshipSenderId,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? friendshipStatus,
    String? friendshipSenderId,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      friendshipStatus: friendshipStatus ?? this.friendshipStatus,
      friendshipSenderId: friendshipSenderId ?? this.friendshipSenderId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        email,
        friendshipStatus,
        friendshipSenderId,
        avatarUrl,
      ];
}
