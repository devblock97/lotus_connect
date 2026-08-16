import 'package:lotus_connect/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.fullName,
    super.friendshipStatus,
    super.friendshipSenderId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      friendshipStatus: json['friendshipStatus'] as String?,
      friendshipSenderId: json['friendshipSenderId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (fullName != null) 'fullName': fullName,
      if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
      if (friendshipSenderId != null) 'friendshipSenderId': friendshipSenderId,
    };
  }
}
