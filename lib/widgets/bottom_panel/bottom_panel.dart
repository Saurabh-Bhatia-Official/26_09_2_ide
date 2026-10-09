import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';
import 'terminal_view.dart';
import 'problems_view.dart';
import 'output_view.dart';
import 'debug_console_view.dart';
import 'ports_view.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    if (!wp.isBottomPanelOpen) return const SizedBox.shrink();

    Widget content;
    switch (wp.bottomPanelTab) {
      case BottomPanelTab.terminal:
        content = const TerminalView();
        break;
      case BottomPanelTab.problems:
        content = const ProblemsView();
        break;
      case BottomPanelTab.output:
        content = const OutputView();
        break;
      case BottomPanelTab.debugConsole:
        content = const DebugConsoleView();
        break;
      case BottomPanelTab.ports:
        content = const PortsView();
        break;
    }

    final tabs = [
      _BottomTabItem(tab: BottomPanelTab.terminal, label: 'Terminal', icon: Icons.terminal),
      _BottomTabItem(
        tab: BottomPanelTab.problems,
        label: 'Problems',
        icon: Icons.cancel_outlined,
        badge: wp.diagnostics.length,
      ),
      _BottomTabItem(tab: BottomPanelTab.output, label: 'Output', icon: Icons.description_outlined),
      _BottomTabItem(tab: BottomPanelTab.debugConsole, label: 'Debug Console', icon: Icons.sensors),
      _BottomTabItem(
        tab: BottomPanelTab.ports,
        label: 'Ports',
        icon: Icons.public,
        badge: wp.ports.where((p) => p.status == 'running').length,
      ),
    ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.bgSurface,
        border: Border(top: BorderSide(color: theme.borderSubtle)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.borderSubtle)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final item = tabs[index];
                      final isActive = wp.bottomPanelTab == item.tab;

                      return InkWell(
                        onTap: () => wp.setBottomPanelTab(item.tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive ? theme.accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 13,
                                color: isActive ? const Color(0xFF38BDF8) : theme.textDim,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isActive ? Colors.white : theme.textMuted,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              if (item.badge != null && item.badge! > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${item.badge}',
                                    style: TextStyle(fontSize: 9, color: theme.accent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  tooltip: 'Close Panel',
                  onPressed: wp.toggleBottomPanel,
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _BottomTabItem {
  final BottomPanelTab tab;
  final String label;
  final IconData icon;
  final int? badge;

  _BottomTabItem({required this.tab, required this.label, required this.icon, this.badge});
}
