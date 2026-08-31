import 'package:equatable/equatable.dart';
import 'package:lotus_connect/features/auth/data/models/user_model.dart';

class AuthResponseModel extends Equatable {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.isSuccess,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      isSuccess: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String? message;
  final bool? isSuccess;

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  List<Object?> get props => [
        user,
        accessToken,
        refreshToken,
        isSuccess,
        message,
      ];
}

class AuthErrorResponseModel extends Equatable {
  const AuthErrorResponseModel({
    required this.isSuccess,
    required this.message,
  });

  final bool isSuccess;
  final String message;

  @override
  List<Object?> get props => [isSuccess, message];
}
