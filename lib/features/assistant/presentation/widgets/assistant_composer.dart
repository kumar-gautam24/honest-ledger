import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_theme.dart';

/// The floating message composer: a bordered field and send button in one
/// rounded surface that hovers above the transcript. The border warms to brass
/// on focus, the send button only lights up when there's something to send, and
/// sending fires a light haptic. The keyboard stays up between turns.
class AssistantComposer extends StatefulWidget {
  const AssistantComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Locked while the assistant is working or a write is awaiting confirmation.
  final bool busy;
  final VoidCallback onSend;

  @override
  State<AssistantComposer> createState() => _AssistantComposerState();
}

class _AssistantComposerState extends State<AssistantComposer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    widget.focusNode.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    widget.focusNode.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  bool get _canSend =>
      !widget.busy && widget.controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    hapticTap();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final focused = widget.focusNode.hasFocus;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            border: Border.all(
              color: focused ? c.accent : c.hairline,
              width: focused ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: context.text.bodyLarge,
                  cursorColor: c.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Ask about your money…',
                    hintStyle: context.text.bodyLarge?.copyWith(
                      color: c.textLow,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _SendButton(enabled: _canSend, onTap: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedScale(
      scale: enabled ? 1 : 0.9,
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      child: Material(
        color: enabled ? c.accent : c.surfaceHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 20,
              color: enabled ? c.background : c.textLow,
            ),
          ),
        ),
      ),
    );
  }
}
