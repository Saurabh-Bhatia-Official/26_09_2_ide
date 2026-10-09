import 'package:flutter/material.dart';
import '../../models/file_item.dart';
import '../../utils/syntax_highlighter.dart';

class DiffEditorView extends StatelessWidget {
  final FileItem file;
  final VoidCallback onClose;
  final dynamic theme;

  const DiffEditorView({
    super.key,
    required this.file,
    required this.onClose,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final originalContent = file.content
        .replaceAll('v1.0.0', 'v0.9.2')
        .replaceAll('142', '120');

    final originalLines = originalContent.split('\n');
    final modifiedLines = file.content.split('\n');

    return Container(
      color: theme.editorBg,
      child: Column(
        children: [
          // Header
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.commit, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  'Diff: ${file.name}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Working Tree ↔ HEAD)',
                  style: TextStyle(fontSize: 10, color: theme.textDim),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 12),
                  label: const Text('Keep Changes', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Accepted working tree changes')),
                    );
                    onClose();
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 15),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Side-by-side Diff View
          Expanded(
            child: Row(
              children: [
                // Original View
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: theme.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: Colors.red.withValues(alpha: 0.12),
                          child: const Text('ORIGINAL (HEAD)', style: TextStyle(color: Color(0xFFF43F5E), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: originalLines.length,
                            itemBuilder: (context, index) {
                              final line = originalLines[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(fontSize: 11, color: theme.textDim, fontFamily: 'monospace'),
                                    ),
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: SyntaxHighlighter.highlight(line, file.language, theme.isDark),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Modified View
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.green.withValues(alpha: 0.12),
                        child: const Text('MODIFIED (WORKING TREE)', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: modifiedLines.length,
                          itemBuilder: (context, index) {
                            final line = modifiedLines[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 11, color: theme.textDim, fontFamily: 'monospace'),
                                  ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: SyntaxHighlighter.highlight(line, file.language, theme.isDark),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
