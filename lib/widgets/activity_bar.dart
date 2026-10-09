import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../models/ide_types.dart';
import '../constants/app_constants.dart';

class ActivityBar extends StatelessWidget {
  const ActivityBar({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    final topItems = [
      _ActivityItem(
        tab: ActivityTab.explorer,
        icon: Icons.folder_copy_outlined,
        tooltip: 'Explorer (Ctrl+Shift+E)',
      ),
      _ActivityItem(
        tab: ActivityTab.search,
        icon: Icons.search,
        tooltip: 'Search (Ctrl+Shift+F)',
      ),
      _ActivityItem(
        tab: ActivityTab.git,
        icon: Icons.fork_right_outlined,
        tooltip: 'Source Control (Ctrl+Shift+G)',
        badge: wp.stagedFiles.length + 1,
      ),
      _ActivityItem(
        tab: ActivityTab.debug,
        icon: Icons.play_circle_outline,
        tooltip: 'Run and Debug (Ctrl+Shift+D)',
      ),
      _ActivityItem(
        tab: ActivityTab.extensions,
        icon: Icons.extension_outlined,
        tooltip: 'Extensions (Ctrl+Shift+X)',
        badge: wp.extensions.where((e) => e.installed).length,
      ),
      _ActivityItem(
        tab: ActivityTab.ai,
        icon: Icons.auto_awesome,
        tooltip: '${AppConstants.appName} AI Copilot & Agent (Ctrl+Shift+A)',
        iconColor: const Color(0xFF38BDF8),
        isAi: true,
      ),
      _ActivityItem(
        tab: ActivityTab.remote,
        icon: Icons.cloud_queue_outlined,
        tooltip: 'Remote & Cloud Workspaces',
      ),
      _ActivityItem(
        tab: ActivityTab.testing,
        icon: Icons.science_outlined,
        tooltip: 'Testing',
      ),
    ];

    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: theme.bgBase,
        border: Border(right: BorderSide(color: theme.borderSubtle)),
      ),
      child: Column(
        children: [
          // Top group
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: topItems.length,
              itemBuilder: (context, index) {
                final item = topItems[index];
                final isActive = item.isAi
                    ? wp.isAiPanelOpen
                    : (wp.activityTab == item.tab && wp.isSidebarOpen);

                return _buildButton(
                  context,
                  icon: item.icon,
                  tooltip: item.tooltip,
                  isActive: isActive,
                  badge: item.badge,
                  iconColor: item.iconColor,
                  onTap: () {
                    if (item.isAi) {
                      wp.toggleAiPanel();
                    } else {
                      if (wp.activityTab == item.tab && wp.isSidebarOpen) {
                        wp.toggleSidebar();
                      } else {
                        wp.setActivityTab(item.tab);
                        if (!wp.isSidebarOpen) wp.toggleSidebar();
                      }
                    }
                  },
                );
              },
            ),
          ),

          // Bottom group
          _buildButton(
            context,
            icon: Icons.account_circle_outlined,
            tooltip: '${AppConstants.appShortName} Account: ${AppConstants.defaultUserAccount} (${AppConstants.defaultUserTier})',
            isActive: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('${AppConstants.appName} Developer Account: ${AppConstants.defaultUserAccount} [${AppConstants.defaultUserTier}]'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildButton(
            context,
            icon: Icons.settings_outlined,
            tooltip: 'Settings (Ctrl+,)',
            isActive: wp.activityTab == ActivityTab.settings && wp.isSidebarOpen,
            onTap: () {
              wp.setActivityTab(ActivityTab.settings);
              if (!wp.isSidebarOpen) wp.toggleSidebar();
            },
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required bool isActive,
    int? badge,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final wp = context.read<WorkspaceProvider>();
    final theme = wp.theme;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isActive ? theme.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? Colors.white
                    : (iconColor ?? theme.textMuted),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: -6,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      badge.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem {
  final ActivityTab tab;
  final IconData icon;
  final String tooltip;
  final int? badge;
  final Color? iconColor;
  final bool isAi;

  _ActivityItem({
    required this.tab,
    required this.icon,
    required this.tooltip,
    this.badge,
    this.iconColor,
    this.isAi = false,
  });
}
