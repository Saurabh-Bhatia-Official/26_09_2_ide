import 'package:flutter/material.dart';

class SyntaxHighlighter {
  static const List<String> keywords = [
    'fn', 'let', 'mut', 'pub', 'struct', 'enum', 'impl', 'use', 'mod', 'match',
    'if', 'else', 'for', 'while', 'loop', 'return', 'async', 'await', 'trait',
    'type', 'const', 'static', 'ref', 'move', 'self', 'Self', 'super', 'crate',
    'import', 'from', 'export', 'default', 'class', 'interface', 'extends',
    'implements', 'function', 'var', 'const', 'switch', 'case', 'break',
    'continue', 'new', 'this', 'throw', 'try', 'catch', 'finally', 'typeof',
    'instanceof', 'void', 'null', 'undefined', 'true', 'false', 'def', 'class',
    'elif', 'pass', 'lambda', 'with', 'as', 'yield', 'global', 'nonlocal',
    'final', 'abstract', 'void', 'override', 'late', 'required', 'is', 'in'
  ];

  static const List<String> types = [
    'String', 'int', 'double', 'num', 'bool', 'List', 'Map', 'Set', 'Future',
    'Stream', 'Widget', 'BuildContext', 'State', 'StatefulWidget', 'StatelessWidget',
    'i8', 'i16', 'i32', 'i64', 'i128', 'isize', 'u8', 'u16', 'u32', 'u64', 'u128',
    'usize', 'f32', 'f64', 'char', 'str', 'bool', 'Option', 'Result', 'Some', 'None',
    'Ok', 'Err', 'Vec', 'Box', 'Rc', 'Arc', 'Mutex', 'RwLock', 'PathBuf', 'File',
    'number', 'string', 'boolean', 'any', 'never', 'unknown', 'object', 'Promise',
    'Array', 'Record', 'Partial', 'Readonly'
  ];

  static TextSpan highlight(String text, String language, bool isDark) {
    if (text.isEmpty) {
      return const TextSpan(text: '');
    }

    final Color keywordColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
    final Color typeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final Color stringColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final Color commentColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final Color numberColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    final Color punctuationColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color defaultColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

    final List<TextSpan> spans = [];

    // Simple tokenizer regex
    final RegExp tokenRegex = RegExp(
      r'(//[^\n]*)|' // Line comment
      r'(/\*[\s\S]*?\*/)|' // Block comment
      r'("(?:\\.|[^"\\])*"|' "'" r"(?:\\.|[^'\\])*')|" // String
      r'(\b\d+(?:\.\d+)?\b)|' // Numbers
      r'(\b[a-zA-Z_][a-zA-Z0-9_]*\b)|' // Identifiers / Keywords
      r'([{}()\[\];,.:<>=!+\-*/&|])|' // Punctuation / Operators
      r'([^\s\w{}()\[\];,.:<>=!+\-*/&|"]+)', // Others
      multiLine: true,
    );

    int lastMatchEnd = 0;

    for (final match in tokenRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: defaultColor),
        ));
      }

      final String matchedText = match.group(0)!;

      if (matchedText.startsWith('//') || matchedText.startsWith('/*')) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: commentColor, fontStyle: FontStyle.italic),
        ));
      } else if (matchedText.startsWith('"') || matchedText.startsWith("'")) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: stringColor),
        ));
      } else if (RegExp(r'^\d+(\.\d+)?$').hasMatch(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: numberColor),
        ));
      } else if (keywords.contains(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: keywordColor, fontWeight: FontWeight.w600),
        ));
      } else if (types.contains(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: typeColor),
        ));
      } else if (RegExp(r'^[{}()\[\];,.:<>=!+\-*/&|]$').hasMatch(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: punctuationColor),
        ));
      } else {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: defaultColor),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: defaultColor),
      ));
    }

    return TextSpan(children: spans);
  }
}
