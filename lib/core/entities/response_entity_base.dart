import 'package:equatable/equatable.dart';

class ResponseEntityBase extends Equatable {
  const ResponseEntityBase({
    this.isSuccess,
    this.message,
  });

  factory ResponseEntityBase.fromJson(Map<String, dynamic> json) {
    return ResponseEntityBase(
      isSuccess: json['success'] as bool?,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': isSuccess,
        'message': message,
      };

  final bool? isSuccess;
  final String? message;

  @override
  List<Object?> get props => [isSuccess, message];
}
