import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/assistant_controller.dart';
import '../widgets/assistant_composer.dart';
import '../widgets/assistant_empty_state.dart';
import '../widgets/chat_transcript.dart';
import '../widgets/confirm_action_card.dart';

/// The money assistant: a chat with your own finances. Chromeless and
/// full-screen — the transcript owns the scroll, the composer floats, and
/// everything leans on the app's ink-and-brass identity.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(assistantControllerProvider.notifier).send(text);
  }

  Future<void> _newChat() async {
    _focus.unfocus();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start a new chat?'),
        content: const Text('This clears the current conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('New chat'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(assistantControllerProvider.notifier).newChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = ref.watch(assistantControllerProvider);
    final media = MediaQuery.of(context);

    final topReserve = media.padding.top + 52;
    final bottomReserve = 92 + media.viewPadding.bottom;

    return Scaffold(
      backgroundColor: c.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // The conversation (or the first-run canvas).
            Positioned.fill(
              child: state.isEmpty
                  ? AssistantEmptyState(
                      onPick: _send,
                      topPadding: topReserve,
                      bottomPadding: bottomReserve,
                    )
                  : ChatTranscript(
                      entries: state.entries,
                      isBusy: state.isBusy,
                      error: state.error,
                      onRetry: () => ref
                          .read(assistantControllerProvider.notifier)
                          .retry(),
                      pendingCard: state.pending == null
                          ? null
                          : ConfirmActionCard(
                              action: state.pending!,
                              busy: state.isBusy,
                              onConfirm: (edited) => ref
                                  .read(assistantControllerProvider.notifier)
                                  .confirm(edited),
                              onCancel: () => ref
                                  .read(assistantControllerProvider.notifier)
                                  .cancel(),
                            ),
                      topPadding: topReserve,
                      bottomPadding: bottomReserve,
                    ),
            ),

            // A soft scrim so scrolled text fades under the floating controls.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: media.padding.top + 64,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [c.background, c.background.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),

            // Floating chrome: back, and (when there's a chat) new-chat.
            Positioned(
              top: media.padding.top + AppSpacing.xs,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ChromeButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  if (!state.isEmpty)
                    _ChromeButton(
                      icon: Icons.edit_square,
                      tooltip: 'New chat',
                      onTap: _newChat,
                    ),
                ],
              ),
            ),

            // The floating composer.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AssistantComposer(
                controller: _input,
                focusNode: _focus,
                busy: state.isBusy || state.pending != null,
                onSend: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet circular icon button for the floating top chrome.
class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface.withValues(alpha: 0.6),
        shape: CircleBorder(side: BorderSide(color: c.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: c.textHi),
          ),
        ),
      ),
    );
  }
}
