import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingHeart {
  FloatingHeart({
    required this.id,
    required this.color,
    required this.icon,
    required this.startX,
    required this.startY,
    required this.size,
    required this.swayFrequency,
    required this.swayAmplitude,
  });

  final int id;
  final Color color;
  final IconData icon;
  final double startX;
  final double startY;
  final double size;
  final double swayFrequency;
  final double swayAmplitude;
  double progress = 0;
}

class FloatingHeartsOverlay extends StatefulWidget {
  const FloatingHeartsOverlay({
    required this.burstTick,
    super.key,
  });

  final int burstTick;

  @override
  State<FloatingHeartsOverlay> createState() => _FloatingHeartsOverlayState();
}

class _FloatingHeartsOverlayState extends State<FloatingHeartsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tickerController;
  final List<FloatingHeart> _hearts = [];
  final math.Random _random = math.Random();
  int _lastTick = 0;
  int _nextId = 0;

  static const List<Color> _heartColors = [
    Color(0xFFFF2D55),
    Color(0xFFFF375F),
    Color(0xFFFF6482),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFFAF52DE),
    Color(0xFF5856D6),
    Color(0xFF00C7BE),
  ];

  static const List<IconData> _reactionIcons = [
    Icons.favorite,
    Icons.favorite,
    Icons.favorite,
    Icons.local_fire_department,
    Icons.star_rounded,
    Icons.favorite_border,
  ];

  @override
  void initState() {
    super.initState();
    _lastTick = widget.burstTick;
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateHearts);
    _tickerController.repeat();
  }

  @override
  void didUpdateWidget(FloatingHeartsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.burstTick != _lastTick) {
      final count = math.min(widget.burstTick - _lastTick, 6);
      for (var i = 0; i < count; i++) {
        _spawnHeart();
      }
      _lastTick = widget.burstTick;
    }
  }

  void _spawnHeart() {
    final color = _heartColors[_random.nextInt(_heartColors.length)];
    final icon = _reactionIcons[_random.nextInt(_reactionIcons.length)];
    final size = 20.0 + _random.nextDouble() * 16.0;

    _hearts.add(
      FloatingHeart(
        id: _nextId++,
        color: color,
        icon: icon,
        startX: 40.0 + _random.nextDouble() * 30.0,
        startY: 20,
        size: size,
        swayFrequency: 2.0 + _random.nextDouble() * 3.0,
        swayAmplitude: 15.0 + _random.nextDouble() * 25.0,
      ),
    );
  }

  void _updateHearts() {
    if (_hearts.isEmpty) return;

    setState(() {
      for (final heart in _hearts) {
        heart.progress += 0.018;
      }
      _hearts.removeWhere((heart) => heart.progress >= 1.0);
    });
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: _hearts.map(_buildSingleHeart).toList(),
      ),
    );
  }

  Widget _buildSingleHeart(FloatingHeart heart) {
    final t = heart.progress;
    // Ascend upward
    final bottom = heart.startY + (t * 340.0);
    // Sway horizontally with sine wave
    final sway =
        math.sin(t * math.pi * heart.swayFrequency) * heart.swayAmplitude;
    final right = heart.startX + sway;

    // Scale: pop in quickly, stay, fade out
    final scale = t < 0.15 ? (t / 0.15) : 1.0;
    final opacity = t > 0.65 ? ((1.0 - t) / 0.35).clamp(0.0, 1.0) : 1.0;

    return Positioned(
      bottom: bottom,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Icon(
            heart.icon,
            size: heart.size,
            color: heart.color,
            shadows: [
              Shadow(
                color: heart.color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
