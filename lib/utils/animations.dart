import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final int index;
  final int delayStepMs;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 14),
    this.index = 0,
    this.delayStepMs = 30,
  });

  @override
  Widget build(BuildContext context) {
    final total = duration + Duration(milliseconds: index * delayStepMs);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: curve,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(beginOffset.dx * (1 - t), beginOffset.dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
