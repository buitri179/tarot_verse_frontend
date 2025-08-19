import 'dart:math';
import 'package:flutter/material.dart';

class StarField extends StatefulWidget {
  const StarField({super.key});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _stars = List.generate(80, (index) {
      return _Star(
        left: _rand.nextDouble(),
        top: _rand.nextDouble(),
        size: _rand.nextDouble() * 2 + 0.5,
        phase: _rand.nextDouble() * 2 * pi,
      );
    });

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _StarPainter(_stars, _controller.value),
          );
        },
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final x = s.left * size.width;
      final y = s.top * size.height;
      final twinkle = (sin(t * 2 * pi + s.phase) + 1) / 2;
      final r = s.size * (0.6 + 0.8 * twinkle);
      paint.color = Colors.white.withOpacity(0.2 + 0.8 * twinkle);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.t != t;
}

class _Star {
  final double left;
  final double top;
  final double size;
  final double phase;
  _Star({
    required this.left,
    required this.top,
    required this.size,
    required this.phase,
  });
}
