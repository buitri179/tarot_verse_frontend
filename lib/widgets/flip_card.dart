import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final void Function()? onFlipEnd;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 500),
    this.onFlipEnd,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isFront = !_isFront;
          widget.onFlipEnd?.call();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_controller.isAnimating) return;
    if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    } else if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          // angle from 0 -> pi
          final angle = _anim.value * 3.1415926535;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          // Show front when angle < pi/2
          final showingFront = angle < 3.1415926535 / 2;

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: showingFront ? widget.front : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(3.1415926535),
              child: widget.back,
            ),
          );
        },
      ),
    );
  }
}
