import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';

class MobileKeyboardBar extends StatelessWidget {
  const MobileKeyboardBar({super.key});

  static const symbols = [
    'Tab', '{', '}', '(', ')', '[', ']', ';', ':', '=>', '"', "'", '=', '+', '-', '*', '/', '&', '|', '!'
  ];

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final activeFile = wp.activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    final theme = wp.theme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.bgSurface,
        border: Border(top: BorderSide(color: theme.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: symbols.length,
        separatorBuilder: (_, _) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final sym = symbols[index];
          return InkWell(
            onTap: () {
              final insert = sym == 'Tab' ? '  ' : sym;
              wp.updateFileContent(activeFile.path, '${activeFile.content}$insert');
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              constraints: const BoxConstraints(minWidth: 32),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.border),
              ),
              child: Text(
                sym,
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
