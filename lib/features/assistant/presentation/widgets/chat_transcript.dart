import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/assistant_state.dart';
import 'assistant_error_inline.dart';
import 'assistant_message.dart';
import 'scroll_to_bottom_button.dart';
import 'status_line.dart';
import 'typing_dots.dart';
import 'user_message.dart';

/// The scrolling conversation. Owns all scroll behaviour so it reads the way a
/// good chat should:
///
/// * It only auto-scrolls when you're already at the bottom — scrolling up to
///   read history is never interrupted by new content or the streaming reveal.
/// * A jump-to-latest button appears when you're scrolled up, with a brass dot
///   when new content arrived meanwhile; both track the scroll position live.
/// * Sending always returns you to the bottom (that's your intent), and the
///   keyboard opening keeps the last turn in view.
/// * Dragging the list dismisses the keyboard.
class ChatTranscript extends StatefulWidget {
  const ChatTranscript({
    super.key,
    required this.entries,
    required this.isBusy,
    required this.error,
    required this.onRetry,
    required this.pendingCard,
    required this.topPadding,
    required this.bottomPadding,
  });

  final List<ChatEntry> entries;
  final bool isBusy;
  final String? error;
  final VoidCallback onRetry;

  /// The confirm-action card, built by the screen when a write is pending.
  final Widget? pendingCard;

  /// Space to keep clear of the top scrim / floating chrome and the composer.
  final double topPadding;
  final double bottomPadding;

  @override
  State<ChatTranscript> createState() => _ChatTranscriptState();
}

class _ChatTranscriptState extends State<ChatTranscript>
    with WidgetsBindingObserver {
  static const _pinThreshold = 120.0;

  final _sc = ScrollController();

  /// Ids present at mount (restored history) — these never re-animate.
  late final Set<String> _initialIds =
      widget.entries.map((e) => e.id).toSet();

  bool _pinned = true;
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sc.addListener(_onScroll);
    // Land at the latest turn for restored conversations.
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Keyboard open/close: keep the last turn visible if we were at the bottom.
    if (_pinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    }
  }

  void _onScroll() {
    if (!_sc.hasClients) return;
    final atBottom =
        _sc.position.maxScrollExtent - _sc.offset <= _pinThreshold;
    if (atBottom != _pinned) {
      setState(() {
        _pinned = atBottom;
        if (atBottom) _hasUnread = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChatTranscript old) {
    super.didUpdateWidget(old);

    final grew = widget.entries.length > old.entries.length;
    final newestIsUser =
        widget.entries.isNotEmpty && widget.entries.last.role == ChatRole.user;

    if (grew && newestIsUser) {
      // The user just sent — always return to the bottom and re-pin.
      _pinned = true;
      _hasUnread = false;
      _scheduleScroll(animated: true);
      return;
    }

    // Any other new content (assistant text, status, typing, error, a pending
    // card): follow it only if we're pinned; otherwise flag it as unread.
    final contentChanged = grew ||
        widget.isBusy != old.isBusy ||
        (widget.error != null) != (old.error != null) ||
        (widget.pendingCard != null) != (old.pendingCard != null);
    if (!contentChanged) return;

    if (_pinned) {
      _scheduleScroll(animated: true);
    } else if (mounted) {
      setState(() => _hasUnread = true);
    }
  }

  void _scheduleScroll({required bool animated}) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _jumpToBottom(animated: animated));
  }

  void _jumpToBottom({bool animated = false}) {
    if (!_sc.hasClients) return;
    final target = _sc.position.maxScrollExtent;
    if (animated) {
      _sc.animateTo(target, duration: AppMotion.base, curve: AppMotion.standard);
    } else {
      _sc.jumpTo(target);
    }
  }

  /// The streaming reveal grew the last turn — stay glued if pinned, but never
  /// yank a user who has scrolled up.
  void _onReveal() {
    if (_pinned) _jumpToBottom();
  }

  void _returnToBottom() {
    setState(() {
      _pinned = true;
      _hasUnread = false;
    });
    _jumpToBottom(animated: true);
  }

  List<Widget> _rows() {
    final rows = <Widget>[];
    for (final entry in widget.entries) {
      final isNew = !_initialIds.contains(entry.id);
      final Widget row = switch (entry.role) {
        ChatRole.user => UserMessage(text: entry.text),
        ChatRole.assistant => AssistantMessage(
            key: ValueKey(entry.id),
            entry: entry,
            animate: isNew,
            onReveal: _onReveal,
          ),
        ChatRole.status => StatusLine(text: entry.text),
      };
      // Fade restored turns in? No — only genuinely new user/status turns get
      // the entrance; the assistant animates via its own reveal.
      rows.add(
        isNew && entry.role != ChatRole.assistant
            ? EntranceFade(index: 0, child: row)
            : row,
      );
    }

    if (widget.error != null) {
      rows.add(AssistantErrorInline(
        message: widget.error!,
        onRetry: widget.onRetry,
      ));
    }
    if (widget.pendingCard != null) rows.add(widget.pendingCard!);

    final lastIsAssistant = widget.entries.isNotEmpty &&
        widget.entries.last.role == ChatRole.assistant;
    if (widget.isBusy && !lastIsAssistant && widget.pendingCard == null) {
      rows.add(const TypingDots());
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    return Stack(
      children: [
        SelectionArea(
          child: ListView(
            controller: _sc,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              widget.topPadding,
              AppSpacing.lg,
              widget.bottomPadding,
            ),
            children: rows,
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: widget.bottomPadding,
          child: ScrollToBottomButton(
            visible: !_pinned,
            hasUnread: _hasUnread,
            onTap: _returnToBottom,
          ),
        ),
      ],
    );
  }
}
