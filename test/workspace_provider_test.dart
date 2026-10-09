import 'package:flutter_test/flutter_test.dart';
import 'package:novaide/constants/app_constants.dart';
import 'package:novaide/providers/workspace_provider.dart';
import 'package:novaide/models/ide_types.dart';

void main() {
  group('WorkspaceProvider Tests', () {
    late WorkspaceProvider provider;

    setUp(() {
      provider = WorkspaceProvider();
    });

    test('Initial state is correct', () {
      expect(provider.workspaceName, 'No Folder Opened');
      expect(provider.isSidebarOpen, true);
      expect(provider.isBottomPanelOpen, false);
      expect(provider.activityTab, ActivityTab.explorer);
      expect(provider.theme.id, anyOf(AppConstants.defaultThemeId, AppConstants.legacyThemeId));
      expect(provider.currentBranch, 'main');
    });

    test('Toggle sidebar and panels', () {
      provider.toggleSidebar();
      expect(provider.isSidebarOpen, false);
      provider.toggleSidebar();
      expect(provider.isSidebarOpen, true);

      provider.toggleBottomPanel();
      expect(provider.isBottomPanelOpen, true);
      provider.toggleBottomPanel();
      expect(provider.isBottomPanelOpen, false);

      provider.toggleAiPanel();
      expect(provider.isAiPanelOpen, true);
      provider.toggleAiPanel();
      expect(provider.isAiPanelOpen, false);
    });

    test('Switch activity tabs', () {
      provider.setActivityTab(ActivityTab.search);
      expect(provider.activityTab, ActivityTab.search);

      provider.setActivityTab(ActivityTab.git);
      expect(provider.activityTab, ActivityTab.git);

      provider.setActivityTab(ActivityTab.debug);
      expect(provider.activityTab, ActivityTab.debug);

      provider.setActivityTab(ActivityTab.extensions);
      expect(provider.activityTab, ActivityTab.extensions);

      provider.setActivityTab(ActivityTab.remote);
      expect(provider.activityTab, ActivityTab.remote);

      provider.setActivityTab(ActivityTab.testing);
      expect(provider.activityTab, ActivityTab.testing);

      provider.setActivityTab(ActivityTab.settings);
      expect(provider.activityTab, ActivityTab.settings);
    });

    test('Switch bottom panel tabs', () {
      provider.setBottomPanelTab(BottomPanelTab.problems);
      expect(provider.bottomPanelTab, BottomPanelTab.problems);

      provider.setBottomPanelTab(BottomPanelTab.output);
      expect(provider.bottomPanelTab, BottomPanelTab.output);

      provider.setBottomPanelTab(BottomPanelTab.debugConsole);
      expect(provider.bottomPanelTab, BottomPanelTab.debugConsole);

      provider.setBottomPanelTab(BottomPanelTab.ports);
      expect(provider.bottomPanelTab, BottomPanelTab.ports);

      provider.setBottomPanelTab(BottomPanelTab.terminal);
      expect(provider.bottomPanelTab, BottomPanelTab.terminal);
    });

    test('File creation, opening tab, editing and closing tab', () {
      provider.createFile('test.dart');
      expect(provider.files.any((f) => f.name == 'test.dart'), true);

      final file = provider.files.firstWhere((f) => f.name == 'test.dart');
      provider.openFile(file);
      expect(provider.openTabs.isNotEmpty, true);
      expect(provider.activeFile?.name, 'test.dart');

      // Update content
      provider.updateFileContent(file.path, 'void main() {}');
      expect(provider.activeFile?.content, 'void main() {}');
      expect(provider.activeFile?.isDirty, true);

      // Save file
      provider.saveActiveFile();
      expect(provider.activeFile?.isDirty, false);

      // Close tab
      final tabId = provider.activeTabId!;
      provider.closeTab(tabId);
      expect(provider.openTabs.isEmpty, true);
    });

    test('Terminal command execution', () {
      provider.runTerminalCommand('echo hello');
      expect(provider.terminalLines.any((l) => l.text.contains('hello')), true);

      provider.runTerminalCommand('clear');
      expect(provider.terminalLines.isEmpty, true);

      provider.runTerminalCommand('help');
      expect(provider.terminalLines.isNotEmpty, true);
    });

    test('Git staging and commit flow', () {
      provider.stageFile('src/main.rs');
      expect(provider.stagedFiles.contains('src/main.rs'), true);
      expect(provider.unstagedFiles.contains('src/main.rs'), false);

      provider.unstageFile('src/main.rs');
      expect(provider.unstagedFiles.contains('src/main.rs'), true);
      expect(provider.stagedFiles.contains('src/main.rs'), false);

      provider.stageFile('src/main.rs');
      provider.setCommitMessage('feat: add main');
      expect(provider.commitMessage, 'feat: add main');

      provider.commit();
      expect(provider.commitMessage, '');
      expect(provider.stagedFiles.isEmpty, true);
      expect(provider.gitHistory.isNotEmpty, true);
    });

    test('Extensions toggle install', () {
      if (provider.extensions.isNotEmpty) {
        final extId = provider.extensions.first.id;
        final initialStatus = provider.extensions.first.installed;
        provider.toggleInstallExtension(extId);
        expect(
          provider.extensions.firstWhere((e) => e.id == extId).installed,
          !initialStatus,
        );
      }
    });

    test('Theme changing and toggling', () {
      provider.setTheme('obsidian');
      expect(provider.theme.id, 'obsidian');

      provider.setTheme('white-corporate');
      expect(provider.theme.id, 'white-corporate');
      expect(provider.theme.isDark, false);
      expect(provider.theme.name, 'White Corporate');

      provider.setTheme('light-modern');
      expect(provider.theme.isDark, false);

      provider.toggleTheme();
      expect(provider.theme.isDark, true);
    });

    test('AI Assistant messaging', () {
      provider.sendAiMessage('How do I run tests?');
      expect(provider.aiMessages.any((m) => m.content == 'How do I run tests?'), true);
    });
  });
}
