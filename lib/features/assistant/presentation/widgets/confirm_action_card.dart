import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/proposed_action.dart';

/// The review-before-save card. Renders a [ProposedAction] with editable fields,
/// an old → new diff for edits, and a prominent warning for destructive changes.
/// Nothing is written until Confirm is tapped — the whole point of the flow.
class ConfirmActionCard extends StatefulWidget {
  const ConfirmActionCard({
    super.key,
    required this.action,
    required this.onConfirm,
    required this.onCancel,
    this.busy = false,
  });

  final ProposedAction action;
  final void Function(Map<String, String> edited) onConfirm;
  final VoidCallback onCancel;
  final bool busy;

  @override
  State<ConfirmActionCard> createState() => _ConfirmActionCardState();
}

class _ConfirmActionCardState extends State<ConfirmActionCard> {
  final _text = <String, TextEditingController>{};
  final _values = <String, String>{};

  @override
  void initState() {
    super.initState();
    for (final f in widget.action.fields) {
      if (f.type == ActionFieldType.text || f.type == ActionFieldType.amount) {
        _text[f.key] = TextEditingController(text: f.value);
      } else {
        _values[f.key] = f.value;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _collect() {
    final out = <String, String>{};
    for (final f in widget.action.fields) {
      out[f.key] = _text[f.key]?.text ?? _values[f.key] ?? f.value;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final a = widget.action;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: AppCard(
        bordered: true,
        color: c.surfaceHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon(a.kind),
                    color: a.destructive ? c.cost : c.accent, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(a.title, style: context.text.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(a.summary,
                style: context.text.bodySmall?.copyWith(color: c.textMid)),
            if (a.warning != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: c.cost),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(a.warning!,
                        style: context.text.bodySmall?.copyWith(color: c.cost)),
                  ),
                ],
              ),
            ],
            for (final f in a.fields) ...[
              const SizedBox(height: AppSpacing.lg),
              _field(context, f),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.busy ? null : widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        widget.busy ? null : () => widget.onConfirm(_collect()),
                    style: a.destructive
                        ? FilledButton.styleFrom(
                            backgroundColor: c.cost, foregroundColor: c.background)
                        : null,
                    child: widget.busy
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: c.background),
                          )
                        : Text(_confirmLabel(a.kind)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context, ActionField f) {
    final c = context.colors;
    final Widget input = switch (f.type) {
      ActionFieldType.amount => AppTextField.amount(
          label: f.label,
          controller: _text[f.key],
          textInputAction: TextInputAction.done,
        ),
      ActionFieldType.text => AppTextField(
          label: f.label,
          controller: _text[f.key],
          textInputAction: TextInputAction.done,
        ),
      ActionFieldType.date => _DateField(
          label: f.label,
          iso: _values[f.key]!,
          onChanged: (iso) => setState(() => _values[f.key] = iso),
        ),
      ActionFieldType.choice => _ChoiceField(
          label: f.label,
          selected: _values[f.key]!,
          choices: f.choices,
          onChanged: (v) => setState(() => _values[f.key] = v),
        ),
    };

    if (!f.changed) return input;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        input,
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text('was ${_display(f.type, f.oldValue!)}',
              style: context.text.bodySmall?.copyWith(color: c.textLow)),
        ),
      ],
    );
  }

  String _display(ActionFieldType type, String value) => switch (type) {
        ActionFieldType.amount =>
          Money.format(double.tryParse(value.replaceAll(',', '')) ?? 0),
        ActionFieldType.date => _fmtDate(value),
        _ => value,
      };

  IconData _icon(ProposedActionKind k) => switch (k) {
        ProposedActionKind.addSubscription => Icons.add_rounded,
        ProposedActionKind.editSubscription => Icons.edit_rounded,
        ProposedActionKind.deleteSubscription => Icons.delete_outline_rounded,
        ProposedActionKind.setCardStatement => Icons.credit_card_rounded,
        ProposedActionKind.markStatementPaid => Icons.check_circle_outline_rounded,
        ProposedActionKind.editCard => Icons.credit_card_rounded,
        ProposedActionKind.editEmi => Icons.edit_rounded,
        ProposedActionKind.closeEmi => Icons.task_alt_rounded,
      };

  String _confirmLabel(ProposedActionKind k) => switch (k) {
        ProposedActionKind.deleteSubscription => 'Delete',
        ProposedActionKind.closeEmi => 'Close',
        ProposedActionKind.addSubscription => 'Add',
        _ => 'Save',
      };
}

String _fmtDate(String iso) {
  final d = DateTime.tryParse(iso);
  return d == null ? iso : DateFormat('d MMM yyyy').format(d);
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.iso,
    required this.onChanged,
  });

  final String label;
  final String iso;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
          child: Text(label, style: AppTypography.eyebrow(c)),
        ),
        AppCard(
          onTap: () async {
            final current = DateTime.tryParse(iso) ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: current,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onChanged('${picked.year.toString().padLeft(4, '0')}-'
                  '${picked.month.toString().padLeft(2, '0')}-'
                  '${picked.day.toString().padLeft(2, '0')}');
            }
          },
          child: Row(
            children: [
              Icon(Icons.event_rounded, size: 18, color: c.textMid),
              const SizedBox(width: AppSpacing.md),
              Text(_fmtDate(iso), style: context.text.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.selected,
    required this.choices,
    required this.onChanged,
  });

  final String label;
  final String selected;
  final List<String> choices;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
          child: Text(label, style: AppTypography.eyebrow(c)),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final o in choices)
              ChoiceChip(
                label: Text('${o[0].toUpperCase()}${o.substring(1)}'),
                selected: selected == o,
                onSelected: (_) => onChanged(o),
              ),
          ],
        ),
      ],
    );
  }
}
