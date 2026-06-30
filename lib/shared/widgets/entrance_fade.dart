import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Fades and lifts a list item into place, staggered by [index]. Respects the
/// platform reduce-motion setting (renders instantly when disabled).
class EntranceFade extends StatefulWidget {
  const EntranceFade({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<EntranceFade> createState() => _EntranceFadeState();
}

class _EntranceFadeState extends State<EntranceFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  late final Animation<double> _curved =
      CurvedAnimation(parent: _controller, curve: AppMotion.standard);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      // Cap the delay so long lists don't crawl in.
      final step = AppMotion.stagger * math.min(widget.index, 8);
      Future.delayed(step, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(_curved),
        child: widget.child,
      ),
    );
  }
}
