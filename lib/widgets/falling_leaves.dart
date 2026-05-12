import 'dart:math';
import 'package:flutter/material.dart';

class FallingLeaf {
  double x;
  double y;
  double speed;
  double swayAmplitude;
  double swaySpeed;
  double rotation;
  double rotationSpeed;
  double size;
  double opacity;
  double initialX;
  double phase;

  FallingLeaf({
    required this.x,
    required this.y,
    required this.speed,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.opacity,
    required this.phase,
  }) : initialX = x;
}

class FallingLeavesWidget extends StatefulWidget {
  /// How far down the screen (as a fraction 0.0–1.0) leaves should fully fade out.
  final double fadeOutFraction;

  /// Number of leaves on screen at once.
  final int leafCount;

  const FallingLeavesWidget({
    super.key,
    this.fadeOutFraction = 0.35,
    this.leafCount = 12,
  });

  @override
  State<FallingLeavesWidget> createState() => _FallingLeavesWidgetState();
}

class _FallingLeavesWidgetState extends State<FallingLeavesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FallingLeaf> _leaves = [];
  final Random _random = Random();
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateLeaves);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateLeaves);
    _controller.dispose();
    super.dispose();
  }

  FallingLeaf _createLeaf({bool randomY = false}) {
    final screenWidth = _screenSize.width;
    return FallingLeaf(
      x: _random.nextDouble() * screenWidth,
      y: randomY ? -_random.nextDouble() * _screenSize.height * widget.fadeOutFraction : -_random.nextDouble() * 60 - 20,
      speed: 0.4 + _random.nextDouble() * 0.6,
      swayAmplitude: 15 + _random.nextDouble() * 25,
      swaySpeed: 0.5 + _random.nextDouble() * 1.5,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: 0.01 + _random.nextDouble() * 0.03,
      size: 14 + _random.nextDouble() * 10,
      opacity: 0.5 + _random.nextDouble() * 0.5,
      phase: _random.nextDouble() * 2 * pi,
    );
  }

  void _initLeaves() {
    _leaves.clear();
    for (int i = 0; i < widget.leafCount; i++) {
      _leaves.add(_createLeaf(randomY: true));
    }
  }

  void _updateLeaves() {
    if (_screenSize == Size.zero) return;

    final fadeLimit = _screenSize.height * widget.fadeOutFraction;

    for (int i = 0; i < _leaves.length; i++) {
      final leaf = _leaves[i];
      leaf.y += leaf.speed;
      leaf.x = leaf.initialX + sin(leaf.y * 0.01 * leaf.swaySpeed + leaf.phase) * leaf.swayAmplitude;
      leaf.rotation += leaf.rotationSpeed;

      // Fade out as leaf approaches the fade limit
      if (leaf.y > 0) {
        leaf.opacity = (1.0 - (leaf.y / fadeLimit)).clamp(0.0, 1.0) * 0.7;
      }

      // Reset leaf when it's fully faded or past the limit
      if (leaf.y > fadeLimit || leaf.opacity <= 0) {
        _leaves[i] = _createLeaf();
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final newSize = MediaQuery.of(context).size;
    if (_screenSize != newSize) {
      _screenSize = newSize;
      if (_leaves.isEmpty) {
        _initLeaves();
      }
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _LeavesPainter(leaves: _leaves),
      ),
    );
  }
}

class _LeavesPainter extends CustomPainter {
  final List<FallingLeaf> leaves;

  _LeavesPainter({required this.leaves});

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      if (leaf.opacity <= 0) continue;

      canvas.save();
      canvas.translate(leaf.x, leaf.y);
      canvas.rotate(leaf.rotation);

      // Draw a simple bamboo leaf shape
      final paint = Paint()
        ..color = Color.fromRGBO(107, 142, 35, leaf.opacity)
        ..style = PaintingStyle.fill;

      final path = Path();
      final w = leaf.size;
      final h = leaf.size * 0.35;

      // Leaf shape: tapered ellipse
      path.moveTo(-w / 2, 0);
      path.quadraticBezierTo(-w / 4, -h, 0, -h * 0.8);
      path.quadraticBezierTo(w / 4, -h, w / 2, 0);
      path.quadraticBezierTo(w / 4, h, 0, h * 0.8);
      path.quadraticBezierTo(-w / 4, h, -w / 2, 0);
      path.close();

      canvas.drawPath(path, paint);

      // Center vein
      final veinPaint = Paint()
        ..color = Color.fromRGBO(85, 120, 20, leaf.opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawLine(Offset(-w / 2 + 2, 0), Offset(w / 2 - 2, 0), veinPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter oldDelegate) => true;
}
