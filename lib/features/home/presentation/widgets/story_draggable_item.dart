import 'package:flutter/material.dart';

class StoryDraggableItem extends StatefulWidget {
  const StoryDraggableItem({
    required this.child,
    required this.offset,
    required this.scale,
    required this.rotation,
    required this.canvasSize,
    required this.onTransformUpdate,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Offset offset;
  final double scale;
  final double rotation;
  final Size canvasSize;
  final void Function(Offset newOffset, double newScale, double newRotation)
      onTransformUpdate;
  final void Function(Offset globalFocalPoint) onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final VoidCallback? onTap;

  @override
  State<StoryDraggableItem> createState() => _StoryDraggableItemState();
}

class _StoryDraggableItemState extends State<StoryDraggableItem> {
  late Offset _currentOffset;
  late double _baseScale;
  late double _baseRotation;

  @override
  void initState() {
    super.initState();
    _currentOffset = widget.offset;
    _baseScale = widget.scale;
    _baseRotation = widget.rotation;
  }

  @override
  void didUpdateWidget(StoryDraggableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentOffset = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.canvasSize.width;
    final height = widget.canvasSize.height;

    final left = (widget.offset.dx * width).clamp(20.0, width - 20.0);
    final top = (widget.offset.dy * height).clamp(40.0, height - 40.0);

    return Positioned(
      left: left,
      top: top,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onScaleStart: (_) {
            _currentOffset = widget.offset;
            _baseScale = widget.scale;
            _baseRotation = widget.rotation;
            widget.onDragStart();
          },
          onScaleUpdate: (details) {
            final delta = details.focalPointDelta;
            final newX = (_currentOffset.dx + delta.dx / width).clamp(
              0.05,
              0.95,
            );
            final newY = (_currentOffset.dy + delta.dy / height).clamp(
              0.08,
              0.92,
            );

            _currentOffset = Offset(newX, newY);

            final newScale = (_baseScale * details.scale).clamp(0.5, 3.5);
            final newRotation = _baseRotation + details.rotation;

            widget.onTransformUpdate(
              Offset(newX, newY),
              newScale,
              newRotation,
            );
            widget.onDragUpdate(details.focalPoint);
          },
          onScaleEnd: (_) {
            widget.onDragEnd();
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              widget.scale,
              widget.scale,
              1,
            )..rotateZ(widget.rotation),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
