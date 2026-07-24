import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/assistant/presentation/widgets/assistant_markdown.dart';

void main() {
  group('parseInline', () {
    test('plain text is a single run', () {
      expect(
        AssistantMarkdown.parseInline('hello there'),
        const [MdInline(MdInlineKind.plain, 'hello there')],
      );
    });

    test('splits bold from surrounding text', () {
      expect(
        AssistantMarkdown.parseInline('you owe **a lot** now'),
        const [
          MdInline(MdInlineKind.plain, 'you owe '),
          MdInline(MdInlineKind.bold, 'a lot'),
          MdInline(MdInlineKind.plain, ' now'),
        ],
      );
    });

    test('detects a rupee amount as a money run', () {
      expect(
        AssistantMarkdown.parseInline('due ₹42,300 total'),
        const [
          MdInline(MdInlineKind.plain, 'due '),
          MdInline(MdInlineKind.money, '₹42,300'),
          MdInline(MdInlineKind.plain, ' total'),
        ],
      );
    });

    test('handles decimals in amounts', () {
      final runs = AssistantMarkdown.parseInline('₹1,234.50');
      expect(runs, const [MdInline(MdInlineKind.money, '₹1,234.50')]);
    });

    test('mixes bold and money in one line', () {
      final runs = AssistantMarkdown.parseInline('**HDFC** — ₹18,000');
      expect(runs, const [
        MdInline(MdInlineKind.bold, 'HDFC'),
        MdInline(MdInlineKind.plain, ' — '),
        MdInline(MdInlineKind.money, '₹18,000'),
      ]);
    });
  });

  group('parseBlocks', () {
    test('a single line is one paragraph', () {
      final blocks = AssistantMarkdown.parseBlocks('just one line');
      expect(blocks.length, 1);
      expect(blocks.single.kind, MdBlockKind.paragraph);
    });

    test('bullet lines become bullet blocks', () {
      final blocks = AssistantMarkdown.parseBlocks(
        'Your EMIs:\n• HDFC card ₹18,000\n• Car loan ₹12,300',
      );
      expect(blocks.map((b) => b.kind).toList(), [
        MdBlockKind.paragraph,
        MdBlockKind.bullet,
        MdBlockKind.bullet,
      ]);
    });

    test('recognises dash and asterisk bullets too', () {
      final blocks = AssistantMarkdown.parseBlocks('- one\n* two');
      expect(blocks.every((b) => b.kind == MdBlockKind.bullet), isTrue);
    });

    test('a blank line separates paragraphs', () {
      final blocks = AssistantMarkdown.parseBlocks('first\n\nsecond');
      expect(blocks.length, 2);
      expect(blocks.every((b) => b.kind == MdBlockKind.paragraph), isTrue);
    });

    test('the bullet marker is stripped from content', () {
      final blocks = AssistantMarkdown.parseBlocks('• HDFC ₹18,000');
      final inlines = blocks.single.inlines;
      expect(inlines.first.text.startsWith('HDFC'), isTrue);
      expect(inlines.any((r) => r.kind == MdInlineKind.money), isTrue);
    });
  });
}
