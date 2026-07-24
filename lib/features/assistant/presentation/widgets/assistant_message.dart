import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/assistant_state.dart';
import 'assistant_markdown.dart';

/// One assistant turn, rendered as full-width editorial text (no bubble) with a
/// small brass turn-marker. When [animate] is set, the reply reveals word by
/// word with a trailing caret — a simulated stream that reads as "typing". The
/// reveal is presentation-only: swap in real streamed text later and this widget
/// simply renders whatever it's given (drop the timer).
class AssistantMessage extends StatefulWidget {
  const AssistantMessage({
    super.key,
    required this.entry,
    required this.animate,
    this.onReveal,
  });

  final ChatEntry entry;

  /// Whether this turn is newly arrived (animate) vs. restored history (instant).
  final bool animate;

  /// Called on every reveal tick so the transcript can keep a pinned view glued
  /// to the growing text.
  final VoidCallback? onReveal;

  @override
  State<AssistantMessage> createState() => _AssistantMessageState();
}

class _AssistantMessageState extends State<AssistantMessage> {
  static const _tick = Duration(milliseconds: 22);

  Timer? _timer;
  int _shown = 0;
  bool _init = false;

  String get _text => widget.entry.text;
  bool get _done => _shown >= _text.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.animate || reduceMotion || _text.isEmpty) {
      _shown = _text.length;
    } else {
      _timer = Timer.periodic(_tick, (_) => _advance());
    }
  }

  void _advance() {
    if (_done) {
      _timer?.cancel();
      return;
    }
    // Reveal to the next word or line boundary — one "word" per tick.
    var next = _text.indexOf(' ', _shown + 1);
    if (next == -1) {
      next = _text.length;
    } else {
      next += 1;
    }
    final nl = _text.indexOf('\n', _shown + 1);
    if (nl != -1 && nl + 1 < next) next = nl + 1;

    setState(() => _shown = next.clamp(0, _text.length));
    widget.onReveal?.call();
    if (_done) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The brass turn-marker: a small diamond aligned to the first line.
          Padding(
            padding: const EdgeInsets.only(top: 7, right: AppSpacing.md),
            child: Transform.rotate(
              angle: 0.785398, // 45° — a diamond
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: AssistantMarkdown(
              _text.substring(0, _shown),
              showCaret: !_done,
            ),
          ),
        ],
      ),
    );
  }
}
