import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/assistant_controller.dart';
import '../../application/assistant_state.dart';
import '../../assistant_config.dart';
import '../widgets/confirm_action_card.dart';

/// The money assistant: chat with your own finances. Read-only in this version —
/// it answers from your data; changing data from chat comes next.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(assistantControllerProvider.notifier).send(text);
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppMotion.base,
        curve: AppMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    // Grow the transcript downward as entries and the typing row appear.
    ref.listen(assistantControllerProvider, (_, _) => _scrollToEnd());

    return AppScaffold(
      title: 'Assistant',
      body: Column(
        children: [
          Expanded(
            child: state.isEmpty
                ? _Intro(onPick: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: AppSpacing.screen,
                    itemCount: state.entries.length + (state.isBusy ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.entries.length) return const _Typing();
                      return _Bubble(entry: state.entries[i]);
                    },
                  ),
          ),
          if (state.error != null) _ErrorBar(message: state.error!),
          if (state.pending != null)
            ConfirmActionCard(
              action: state.pending!,
              busy: state.isBusy,
              onConfirm: (edited) =>
                  ref.read(assistantControllerProvider.notifier).confirm(edited),
              onCancel: () =>
                  ref.read(assistantControllerProvider.notifier).cancel(),
            ),
          _Composer(
            controller: _input,
            busy: state.isBusy || state.pending != null,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.entry});

  final ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (entry.role == ChatRole.status) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: Text(
            entry.text,
            style: context.text.bodySmall?.copyWith(color: c.textLow),
          ),
        ),
      );
    }

    final isUser = entry.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isUser ? c.accent.withValues(alpha: 0.16) : c.surface,
            borderRadius: AppRadius.brCard,
            border: Border.all(color: isUser ? c.accent : c.hairline),
          ),
          child: Text(
            entry.text,
            style: context.text.bodyLarge?.copyWith(color: c.textHi),
          ),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('Thinking…',
              style: context.text.bodySmall?.copyWith(color: c.textLow)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask about your money…',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: busy ? null : onSend,
              icon: Icon(Icons.arrow_upward_rounded, color: c.background),
              style: IconButton.styleFrom(backgroundColor: c.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      color: c.cost.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Text(
        message,
        style: context.text.bodySmall?.copyWith(color: c.cost),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onPick});

  final ValueChanged<String> onPick;

  static const _prompts = [
    'What do I owe this month?',
    'Show my cards',
    'How much am I spending on subscriptions?',
    "What's due soon?",
    'Add a ₹649 monthly subscription called Netflix',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: AppSpacing.screen,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Icon(Icons.auto_awesome_rounded, color: c.accent, size: 40),
        const SizedBox(height: AppSpacing.lg),
        Text('Ask about your money', style: context.text.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'I can read your EMIs, subscriptions and cards and answer in plain '
          'language. Try one:',
          style: context.text.bodyMedium?.copyWith(color: c.textMid),
        ),
        if (kAssistantDemoMode) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.science_outlined, size: 14, color: c.textLow),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Demo mode — answers use your real data; no AI model is '
                  'connected yet.',
                  style: context.text.bodySmall?.copyWith(color: c.textLow),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        for (final p in _prompts) ...[
          AppCard(
            onTap: () => onPick(p),
            child: Row(
              children: [
                Expanded(child: Text(p, style: context.text.bodyLarge)),
                Icon(Icons.north_east_rounded, size: 18, color: c.textLow),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
