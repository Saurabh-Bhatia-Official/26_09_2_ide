import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../models/ide_types.dart';
import '../constants/app_constants.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  String _getLanguageLabel(String? lang) {
    switch (lang) {
      case 'rust':
        return 'Rust (2024)';
      case 'typescript':
      case 'tsx':
        return 'TypeScript React';
      case 'python':
        return 'Python 3.12';
      case 'json':
        return 'JSON with Comments';
      case 'toml':
        return 'TOML';
      case 'css':
        return 'CSS 3';
      case 'markdown':
        return 'Markdown';
      case 'dart':
        return 'Dart 3.12';
      default:
        return 'Plain Text';
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    final errorCount =
        wp.diagnostics.where((d) => d.severity == DiagnosticSeverity.error).length;
    final warningCount =
        wp.diagnostics.where((d) => d.severity == DiagnosticSeverity.warning).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1200;
        final isMedium = constraints.maxWidth >= 650;
        final isCompact = constraints.maxWidth < 480;

        return Container(
          height: 24,
          decoration: BoxDecoration(
            color: theme.bgSurface,
            border: Border(top: BorderSide(color: theme.borderSubtle)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Left Group
              if (isWide) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, size: 11, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${AppConstants.appShortName} Cloud: Connected',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Git branch
              Row(
                children: [
                  Icon(Icons.fork_right, size: 12, color: theme.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    '${wp.currentBranch}*',
                    style: TextStyle(fontSize: 11, color: theme.textMain),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              if (isMedium) ...[
                // Sync
                Row(
                  children: [
                    Icon(Icons.sync, size: 11, color: theme.textDim),
                    const SizedBox(width: 2),
                    Text('1↑ 0↓', style: TextStyle(fontSize: 10, color: theme.textDim)),
                  ],
                ),
                const SizedBox(width: 10),
              ],

              // Problems
              InkWell(
                onTap: () {
                  wp.setBottomPanelTab(BottomPanelTab.problems);
                  if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
                },
                child: Row(
                  children: [
                    const Icon(Icons.cancel, size: 11, color: Color(0xFFFECDD3)),
                    const SizedBox(width: 2),
                    Text('$errorCount', style: const TextStyle(fontSize: 10, color: Color(0xFFFECDD3))),
                    const SizedBox(width: 4),
                    const Icon(Icons.warning_amber_rounded, size: 11, color: Color(0xFFFEF08A)),
                    const SizedBox(width: 2),
                    Text('$warningCount', style: const TextStyle(fontSize: 10, color: Color(0xFFFEF08A))),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Workspace trust
              if (wp.isWorkspaceTrusted && isWide) ...[
                const Row(
                  children: [
                    Icon(Icons.verified_user, size: 11, color: Color(0xFFD1FAE5)),
                    SizedBox(width: 3),
                    Text(
                      'Trusted',
                      style: TextStyle(fontSize: 10, color: Color(0xFFD1FAE5), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Right Group
              // AI Copilot
              InkWell(
                onTap: wp.toggleAiPanel,
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF38BDF8)),
                    if (!isCompact) ...[
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.aiAssistantName,
                        style: TextStyle(fontSize: 11, color: theme.textMain, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              if (isWide) ...[
                Text('Ln 29, Col 19', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                const SizedBox(width: 10),
                Text('Spaces: 2', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                const SizedBox(width: 10),
                Text('UTF-8', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                const SizedBox(width: 10),
                Text('LF', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                const SizedBox(width: 10),
              ],

              if (!isCompact) ...[
                Text(
                  _getLanguageLabel(wp.activeFile?.language),
                  style: TextStyle(fontSize: 11, color: theme.textMain, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
              ],

              if (isWide) ...[
                const Row(
                  children: [
                    Icon(Icons.done_all, size: 11, color: Color(0xFFBBF7D0)),
                    SizedBox(width: 3),
                    Text('Prettier', style: TextStyle(fontSize: 10, color: Color(0xFFBBF7D0))),
                  ],
                ),
                const SizedBox(width: 8),
              ],

              Icon(Icons.notifications_none, size: 12, color: theme.textDim),
            ],
          ),
        );
      },
    );
  }
}
