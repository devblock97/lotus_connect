import 'package:equatable/equatable.dart';

class MediaEntity extends Equatable {
  const MediaEntity({
    required this.url,
    this.fileName,
    this.thumbnailUrl,
    this.fileSize,
    this.mimeType,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) {
    return MediaEntity(
      url: json['url'] as String,
      fileName: json['fileName'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'fileName': fileName,
        'thumbnailUrl': thumbnailUrl,
        'fileSize': fileSize,
        'mimeType': mimeType,
      };

  final String url;
  final String? fileName;
  final String? thumbnailUrl;
  final int? fileSize;
  final String? mimeType;

  @override
  List<Object?> get props => [
        url,
        thumbnailUrl,
        fileSize,
        mimeType,
      ];
}
