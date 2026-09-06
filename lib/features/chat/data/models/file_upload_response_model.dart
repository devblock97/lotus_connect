import 'package:equatable/equatable.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';

class FileUploadResponseModel extends Equatable {
  const FileUploadResponseModel({required this.files, required this.fileUrls});

  factory FileUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return FileUploadResponseModel(
      files: (json['files'] as List)
          .map(
            (m) => MediaEntity.fromJson(m as Map<String, dynamic>),
          )
          .toList(),
      fileUrls: (json['fileUrls'] as List).map((f) => f.toString()).toList(),
    );
  }

  final List<MediaEntity> files;
  final List<String> fileUrls;

  @override
  List<Object?> get props => [
        fileUrls,
        files,
      ];
}
