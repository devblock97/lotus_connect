import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.website,
    this.location,
  });

  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String? website;
  final String? location;

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (website != null) 'website': website,
      if (location != null) 'location': location,
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        bio,
        avatarUrl,
        coverUrl,
        website,
        location,
      ];
}
