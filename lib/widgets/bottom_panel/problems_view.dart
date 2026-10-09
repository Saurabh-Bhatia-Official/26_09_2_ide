import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';

class ProblemsView extends StatelessWidget {
  const ProblemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    if (wp.diagnostics.isEmpty) {
      return Container(
        color: theme.editorBg,
        padding: const EdgeInsets.all(12),
        child: Text(
          'No problems have been detected in the workspace.',
          style: TextStyle(fontSize: 12, color: theme.textDim),
        ),
      );
    }

    return Container(
      color: theme.editorBg,
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        itemCount: wp.diagnostics.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final diag = wp.diagnostics[index];
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  diag.severity == DiagnosticSeverity.error
                      ? Icons.cancel
                      : (diag.severity == DiagnosticSeverity.warning
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline),
                  size: 15,
                  color: diag.severity == DiagnosticSeverity.error
                      ? const Color(0xFFF43F5E)
                      : (diag.severity == DiagnosticSeverity.warning
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF38BDF8)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    diag.message,
                    style: TextStyle(fontSize: 12, color: theme.textMain),
                  ),
                ),
                Text(
                  '[${diag.code}]',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontFamily: 'monospace'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 11, color: Color(0xFF38BDF8)),
                  label: const Text('Explain with AI', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    if (!wp.isAiPanelOpen) wp.toggleAiPanel();
                    wp.sendAiMessage(
                        'Explain and fix this diagnostic: ${diag.code} - ${diag.message} at ${diag.file}:${diag.line}');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
