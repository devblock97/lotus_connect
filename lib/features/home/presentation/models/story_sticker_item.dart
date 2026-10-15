import 'package:flutter/material.dart';

enum StoryStickerType {
  location,
  time,
  emoji,
  mention,
  tag,
}

/// A sticker overlay placed on the story canvas.
@immutable
class StoryStickerItem {
  const StoryStickerItem({
    required this.id,
    required this.type,
    required this.text,
    this.offset = const Offset(0.5, 0.5),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.metadata,
  });

  factory StoryStickerItem.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'emoji';
    final type = StoryStickerType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => StoryStickerType.emoji,
    );

    final x = (json['x'] as num?)?.toDouble() ?? 0.5;
    final y = (json['y'] as num?)?.toDouble() ?? 0.5;

    return StoryStickerItem(
      id: json['id'] as String? ?? '',
      type: type,
      text: json['text'] as String? ?? '',
      offset: Offset(x, y),
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final StoryStickerType type;
  final String text;
  final Offset offset;
  final double scale;
  final double rotation;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'x': offset.dx,
        'y': offset.dy,
        'scale': scale,
        'rotation': rotation,
        if (metadata != null) 'metadata': metadata,
      };

  StoryStickerItem copyWith({
    String? id,
    StoryStickerType? type,
    String? text,
    Offset? offset,
    double? scale,
    double? rotation,
    Map<String, dynamic>? metadata,
  }) {
    return StoryStickerItem(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      metadata: metadata ?? this.metadata,
    );
  }
}
