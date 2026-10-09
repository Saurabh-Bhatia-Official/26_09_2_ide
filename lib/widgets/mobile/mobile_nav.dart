import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';

class MobileNav extends StatelessWidget {
  const MobileNav({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: theme.bgSurface,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.folder_copy_outlined,
            label: 'Files',
            isActive: wp.activityTab == ActivityTab.explorer && wp.isMobileDrawerOpen,
            onTap: () {
              wp.setActivityTab(ActivityTab.explorer);
              wp.setMobileDrawerOpen(true);
            },
            theme: theme,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            isActive: wp.activityTab == ActivityTab.search && wp.isMobileDrawerOpen,
            onTap: () {
              wp.setActivityTab(ActivityTab.search);
              wp.setMobileDrawerOpen(true);
            },
            theme: theme,
          ),
          _buildNavItem(
            icon: Icons.fork_right,
            label: 'Git',
            isActive: wp.activityTab == ActivityTab.git && wp.isMobileDrawerOpen,
            onTap: () {
              wp.setActivityTab(ActivityTab.git);
              wp.setMobileDrawerOpen(true);
            },
            theme: theme,
          ),
          _buildNavItem(
            icon: Icons.terminal,
            label: 'Terminal',
            isActive: wp.isBottomPanelOpen,
            onTap: () {
              wp.setBottomPanelTab(BottomPanelTab.terminal);
              if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
            },
            theme: theme,
          ),
          _buildNavItem(
            icon: Icons.auto_awesome,
            label: 'AI Copilot',
            isActive: wp.isAiPanelOpen,
            iconColor: const Color(0xFF38BDF8),
            onTap: wp.toggleAiPanel,
            theme: theme,
          ),
          _buildNavItem(
            icon: Icons.folder_open,
            label: 'Folder',
            isActive: false,
            onTap: wp.openFolder,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? iconColor,
    required VoidCallback onTap,
    required dynamic theme,
  }) {
    final color = isActive
        ? const Color(0xFF38BDF8)
        : (iconColor ?? theme.textMuted);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
