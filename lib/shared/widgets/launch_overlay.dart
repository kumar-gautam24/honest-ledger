import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'brand_mark.dart';

/// One-shot branded launch moment layered over the app on cold start.
///
/// Picks up where the static native splash leaves off (same ink field, same
/// mark): the ring draws itself closed, the drop falls, the motto fades in,
/// then the whole layer dissolves into the app. The app keeps loading
/// underneath the entire time — this never delays interactivity beyond its
/// own fade. Skipped entirely under the platform reduce-motion setting.
///
/// Always rendered in the dark theme: the native splash is ink in both
/// themes, so the handoff must be too.
class LaunchOverlay extends StatefulWidget {
  const LaunchOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<LaunchOverlay> createState() => _LaunchOverlayState();
}

class _LaunchOverlayState extends State<LaunchOverlay>
    with SingleTickerProviderStateMixin {
  // Created eagerly in initState: a lazy `late final` would be first touched
  // by dispose() when reduce-motion skips the animation, and constructing a
  // ticker during unmount throws.
  late final AnimationController _controller;

  /// Motto fades in once the ring is mostly formed.
  late final Animation<double> _motto;

  /// The layer dissolves at the end; input passes through as soon as the
  /// dissolve starts.
  late final Animation<double> _dissolve;

  bool _started = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.launch);
    _motto = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.55, curve: AppMotion.standard),
    );
    _dissolve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.73, 1, curve: AppMotion.exit),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _dismissed = true;
    } else {
      _controller.forward().whenComplete(() {
        if (mounted) setState(() => _dismissed = true);
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
    if (_dismissed) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return IgnorePointer(
              ignoring: _dissolve.value > 0,
              child: Opacity(
                opacity: 1 - _dissolve.value,
                child: Theme(
                  data: AppTheme.dark(),
                  child: Builder(builder: _buildBrandLayer),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrandLayer(BuildContext context) {
    final c = context.colors;
    return ColoredBox(
      color: c.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedBrandMark(size: 132),
          const SizedBox(height: AppSpacing.xl),
          Opacity(
            opacity: _motto.value,
            child: Text(
              AppConstants.motto,
              style: context.text.titleMedium?.copyWith(color: c.textHi),
            ),
          ),
        ],
      ),
    );
  }
}
