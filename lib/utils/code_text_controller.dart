import 'package:flutter/material.dart';
import 'syntax_highlighter.dart';

class CodeTextController extends TextEditingController {
  String language;
  bool isDark;

  CodeTextController({
    super.text,
    this.language = 'rust',
    this.isDark = true,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ??
        const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        );

    final highlighted = SyntaxHighlighter.highlight(text, language, isDark);

    return TextSpan(
      style: defaultStyle,
      children: [highlighted],
    );
  }
}
