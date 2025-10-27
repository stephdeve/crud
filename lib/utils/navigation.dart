import 'package:flutter/material.dart';

Route<T> slideRoute<T>(Widget page, {Duration duration = const Duration(milliseconds: 320)}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(curve);
      final fade = Tween<double>(begin: 0, end: 1).animate(curve);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

Future<T?> push<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(slideRoute<T>(page));
}

Future<T?> replaceWith<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushReplacement<T, T>(slideRoute<T>(page));
}
