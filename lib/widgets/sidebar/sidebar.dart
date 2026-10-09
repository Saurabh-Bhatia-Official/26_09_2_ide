import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';
import 'explorer_view.dart';
import 'search_view.dart';
import 'git_view.dart';
import 'debug_view.dart';
import 'extensions_view.dart';
import 'remote_view.dart';
import 'testing_view.dart';
import 'settings_view.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    if (!wp.isSidebarOpen) return const SizedBox.shrink();

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
      case ActivityTab.debug:
        content = const DebugView();
        break;
      case ActivityTab.extensions:
        content = const ExtensionsView();
        break;
      case ActivityTab.remote:
        content = const RemoteView();
        break;
      case ActivityTab.testing:
        content = const TestingView();
        break;
      case ActivityTab.settings:
        content = const SettingsView();
        break;
      default:
        content = const ExplorerView();
    }

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.bgSurface,
        border: Border(right: BorderSide(color: theme.borderSubtle)),
      ),
      child: content,
    );
  }
}
