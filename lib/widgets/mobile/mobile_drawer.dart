import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';
import '../sidebar/explorer_view.dart';
import '../sidebar/search_view.dart';
import '../sidebar/git_view.dart';
import '../sidebar/extensions_view.dart';
import '../sidebar/settings_view.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    if (!wp.isMobileDrawerOpen) return const SizedBox.shrink();

    final theme = wp.theme;

    Widget content;
    switch (wp.activityTab) {
      case ActivityTab.explorer:
        content = const ExplorerView();
        break;
      case ActivityTab.search:
        content = const SearchView();
        break;
      case ActivityTab.git:
        content = const GitView();
        break;
      case ActivityTab.extensions:
        content = const ExtensionsView();
        break;
      case ActivityTab.settings:
        content = const SettingsView();
        break;
      default:
        content = const ExplorerView();
    }

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => wp.setMobileDrawerOpen(false),
          child: Container(
            color: Colors.black.withValues(alpha: 0.65),
          ),
        ),
        // Drawer Card
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.85 > 320 ? 320 : MediaQuery.of(context).size.width * 0.85,
          child: Container(
            decoration: BoxDecoration(
              color: theme.bgPanel,
              border: Border(right: BorderSide(color: theme.border)),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                // Drawer header
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.bgSurface,
                    border: Border(bottom: BorderSide(color: theme.borderSubtle)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        wp.activityTab.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () => wp.setMobileDrawerOpen(false),
                      ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
