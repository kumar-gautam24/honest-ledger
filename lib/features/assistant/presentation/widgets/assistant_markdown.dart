import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Kinds of inline run the assistant renderer understands.
enum MdInlineKind { plain, bold, money }

/// One inline run of assistant text (a slice of a line).
class MdInline {
  const MdInline(this.kind, this.text);
  final MdInlineKind kind;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is MdInline && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);

  @override
  String toString() => 'MdInline(${kind.name}, "$text")';
}

/// Kinds of block the renderer lays out vertically.
enum MdBlockKind { paragraph, bullet }

/// One block (a paragraph or a single bullet) with its inline runs.
class MdBlock {
  const MdBlock(this.kind, this.inlines);
  final MdBlockKind kind;
  final List<MdInline> inlines;
}

/// A deliberately small Markdown renderer for assistant replies.
///
/// The assistant only ever emits a constrained subset — short paragraphs,
/// `**bold**`, and simple bullets — plus rupee figures we want to read like a
/// statement. Rather than pull a full Markdown dependency, this handles exactly
/// that subset and styles `₹` amounts in tabular mono/brass. Parsing is split
/// into pure functions ([parseInline], [parseBlocks]) so it can be unit-tested
/// without pumping a widget.
class AssistantMarkdown extends StatelessWidget {
  const AssistantMarkdown(this.text, {super.key, this.showCaret = false});

  final String text;

  /// While the reply is streaming in, a brass caret trails the revealed text.
  final bool showCaret;

  /// Matches `**bold**` (group 1) or a rupee amount like `₹1,234.50` (group 2).
  static final _inlinePattern = RegExp(
    r'\*\*(.+?)\*\*|(₹\s?[\d,]+(?:\.\d+)?)',
  );

  static final _bulletPattern = RegExp(r'^\s*[-*•]\s+');

  /// Splits one line into styled runs (plain / bold / money).
  static List<MdInline> parseInline(String line) {
    final out = <MdInline>[];
    var index = 0;
    for (final m in _inlinePattern.allMatches(line)) {
      if (m.start > index) {
        out.add(MdInline(MdInlineKind.plain, line.substring(index, m.start)));
      }
      if (m.group(1) != null) {
        out.add(MdInline(MdInlineKind.bold, m.group(1)!));
      } else {
        out.add(MdInline(MdInlineKind.money, m.group(2)!));
      }
      index = m.end;
    }
    if (index < line.length) {
      out.add(MdInline(MdInlineKind.plain, line.substring(index)));
    }
    return out;
  }

  /// Splits the whole reply into paragraph/bullet blocks. Blank lines are
  /// separators; consecutive text lines fold into one paragraph.
  static List<MdBlock> parseBlocks(String text) {
    final blocks = <MdBlock>[];
    final buffer = <String>[];

    void flushParagraph() {
      if (buffer.isEmpty) return;
      blocks.add(MdBlock(MdBlockKind.paragraph, parseInline(buffer.join(' '))));
      buffer.clear();
    }

    for (final raw in text.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }
      if (_bulletPattern.hasMatch(line)) {
        flushParagraph();
        final content = line.replaceFirst(_bulletPattern, '');
        blocks.add(MdBlock(MdBlockKind.bullet, parseInline(content)));
      } else {
        buffer.add(line.trim());
      }
    }
    flushParagraph();
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = context.text.bodyLarge!.copyWith(color: c.textHi, height: 1.5);
    final blocks = parseBlocks(text);

    // A caret with nothing revealed yet: show it on its own so the assistant
    // lane doesn't jump when the first word lands.
    if (blocks.isEmpty) {
      return showCaret
          ? Text.rich(TextSpan(style: base, children: [_caret(c)]))
          : const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final isLast = i == blocks.length - 1;
      if (i > 0) {
        // Tighter gap between stacked bullets, roomier between paragraphs.
        final tight = block.kind == MdBlockKind.bullet &&
            blocks[i - 1].kind == MdBlockKind.bullet;
        children.add(SizedBox(height: tight ? AppSpacing.xs : AppSpacing.md));
      }
      final caret = isLast && showCaret ? _caret(c) : null;
      children.add(
        block.kind == MdBlockKind.bullet
            ? _bullet(context, block.inlines, base, c, caret)
            : Text.rich(_spans(block.inlines, base, c, caret)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  InlineSpan _caret(AppColors c) => TextSpan(
        text: ' ▌',
        style: TextStyle(color: c.accent, fontWeight: FontWeight.w400),
      );

  Widget _bullet(
    BuildContext context,
    List<MdInline> inlines,
    TextStyle base,
    AppColors c,
    InlineSpan? caret,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: AppSpacing.sm),
          child: Text('•', style: base.copyWith(color: c.accent)),
        ),
        Expanded(child: Text.rich(_spans(inlines, base, c, caret))),
      ],
    );
  }

  TextSpan _spans(
    List<MdInline> inlines,
    TextStyle base,
    AppColors c,
    InlineSpan? caret,
  ) {
    final moneyStyle = AppTypography.money(c, color: c.accent).copyWith(
      fontSize: base.fontSize,
      height: base.height,
    );
    return TextSpan(
      style: base,
      children: [
        for (final run in inlines)
          TextSpan(
            text: run.text,
            style: switch (run.kind) {
              MdInlineKind.plain => null,
              MdInlineKind.bold =>
                base.copyWith(fontWeight: FontWeight.w700, color: c.textHi),
              MdInlineKind.money => moneyStyle,
            },
          ),
        ?caret,
      ],
    );
  }
}
