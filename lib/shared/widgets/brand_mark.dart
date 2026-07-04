import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The app's mark — the "Leak Loop": a recurrence ring that doesn't close,
/// with an ember drop escaping through the gap. Drawn as vectors from theme
/// tokens so it can never drift from the palette. Geometry mirrors
/// assets/brand/icon-master.svg (1024 grid).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      size: Size.square(size),
      painter: BrandMarkPainter(
        ringProgress: 1,
        dropProgress: 1,
        ringColor: c.accent,
        dropColor: c.cost,
      ),
    );
  }
}

/// [BrandMark] with a one-shot draw-in: the ring sweeps closed around the top,
/// then the drop falls through the gap and settles. Renders instantly when the
/// platform reduce-motion setting is on.
class AnimatedBrandMark extends StatefulWidget {
  const AnimatedBrandMark({super.key, this.size = 96});

  final double size;

  @override
  State<AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<AnimatedBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.counter,
  );
  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.62, curve: AppMotion.emphasized),
  );
  late final Animation<double> _drop = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1, curve: AppMotion.standard),
  );
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
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: BrandMarkPainter(
            ringProgress: _ring.value,
            dropProgress: _drop.value,
            ringColor: c.accent,
            dropColor: c.cost,
          ),
        );
      },
    );
  }
}

/// Paints the Leak Loop on a 1024-unit grid scaled to the widget size.
///
/// [ringProgress] grows the ring clockwise from the bottom-left endpoint;
/// [dropProgress] fades the drop in while it falls into place. Both are 0..1
/// and already curved by the caller.
@visibleForTesting
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({
    required this.ringProgress,
    required this.dropProgress,
    required this.ringColor,
    required this.dropColor,
  });

  final double ringProgress;
  final double dropProgress;
  final Color ringColor;
  final Color dropColor;

  // icon-master.svg geometry: ring center (512,428) r 290, gap at 6 o'clock;
  // arc runs the long way from 118° sweeping 304° clockwise to 62°.
  static const double _ringStartDeg = 118;
  static const double _ringSweepDeg = 304;
  static const Offset _ringCenter = Offset(512, 428);
  static const double _ringRadius = 290;
  static const double _ringStroke = 104;

  /// How far above its resting point the drop starts (falls out of the gap).
  static const double _dropFall = 64;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / 1024);

    if (ringProgress > 0) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke
        ..strokeCap = StrokeCap.round
        ..color = ringColor;
      canvas.drawArc(
        Rect.fromCircle(center: _ringCenter, radius: _ringRadius),
        _ringStartDeg * math.pi / 180,
        _ringSweepDeg * math.pi / 180 * ringProgress,
        false,
        ringPaint,
      );
    }

    if (dropProgress > 0) {
      final dropPaint = Paint()
        ..color = dropColor.withValues(alpha: dropProgress);
      canvas.translate(0, -_dropFall * (1 - dropProgress));
      canvas.drawPath(_dropPath(), dropPaint);
    }

    canvas.restore();
  }

  /// Teardrop: tip in the ring gap, bulb below. Mirrors the SVG path.
  Path _dropPath() {
    return Path()
      ..moveTo(512, 756)
      ..cubicTo(542, 790, 568, 820, 568, 852)
      ..arcToPoint(
        const Offset(456, 852),
        radius: const Radius.circular(56),
        largeArc: true,
      )
      ..cubicTo(456, 820, 482, 790, 512, 756)
      ..close();
  }

  @override
  bool shouldRepaint(BrandMarkPainter oldDelegate) {
    if (oldDelegate.ringProgress != ringProgress) return true;
    if (oldDelegate.dropProgress != dropProgress) return true;
    if (oldDelegate.ringColor != ringColor) return true;
    if (oldDelegate.dropColor != dropColor) return true;
    return false;
  }
}
