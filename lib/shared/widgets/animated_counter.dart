import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Animates a number from its previous value to the new one — the signature
/// "wasted" figure rolling up. Honours the platform reduce-motion setting.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = AppMotion.counter,
    this.curve = AppMotion.standard,
  });

  final num value;
  final String Function(num value) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  late num _old = widget.value;

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _old = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      return Text(widget.formatter(widget.value), style: widget.style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _old.toDouble(), end: widget.value.toDouble()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, _) =>
          Text(widget.formatter(value), style: widget.style),
    );
  }
}
