import 'package:flutter_test/flutter_test.dart';
import 'package:novaide/models/platform_mode.dart';
import 'package:novaide/providers/workspace_provider.dart';
import 'package:novaide/services/platform_service.dart';
import 'package:novaide/services/terminal_service.dart';

void main() {
  group('TerminalService & Shell Detection PRD Tests', () {
    tearDown(() {
      TerminalService.clearCache();
      PlatformService.setMockPlatform(null);
    });

    test('TC-04: Windows Shell Detection returns PowerShell and CMD', () {
      final shells = TerminalService.getAvailableShells(overridePlatform: PlatformMode.windows);
      expect(shells.any((s) => s.id == 'powershell'), isTrue);
      expect(shells.any((s) => s.id == 'cmd'), isTrue);
      // Default shell on Windows should be PowerShell
      final defaultShell = shells.firstWhere((s) => s.isDefault);
      expect(defaultShell.id, 'powershell');
    });

    test('TC-05: macOS Shell Detection returns Zsh and Bash', () {
      final shells = TerminalService.getAvailableShells(overridePlatform: PlatformMode.mac);
      expect(shells.any((s) => s.id == 'zsh' || s.id == 'bash'), isTrue);
      final defaultShell = shells.firstWhere((s) => s.isDefault);
      expect(defaultShell.id, 'zsh');
    });

    test('TC-06: Linux Shell Detection returns Bash or Zsh', () {
      final shells = TerminalService.getAvailableShells(overridePlatform: PlatformMode.linux);
      expect(shells.any((s) => s.id == 'bash'), isTrue);
      final defaultShell = shells.firstWhere((s) => s.isDefault);
      expect(defaultShell.id, 'bash');
    });

    test('TC-07: Terminal Working Directory resolves to active project root', () {
      const projectPath = r'D:\Projects\MyApplication';
      final resolved = TerminalService.resolveWorkingDirectory(activeProjectPath: projectPath);
      expect(resolved, projectPath);
    });

    test('TC-08 & EC-02: Project path with spaces resolves correctly', () {
      const spacePath = r'D:\My Projects\Test Application';
      final resolved = TerminalService.resolveWorkingDirectory(activeProjectPath: spacePath);
      expect(resolved, spacePath);
    });

    test('EC-03: Project path with Unicode characters resolves correctly', () {
      const unicodePath = r'D:\Projects\मेराProject';
      final resolved = TerminalService.resolveWorkingDirectory(activeProjectPath: unicodePath);
      expect(resolved, unicodePath);
    });

    test('EC-04: Network project path resolves without crashing', () {
      const networkPath = r'\\server\projects\MyProject';
      final resolved = TerminalService.resolveWorkingDirectory(activeProjectPath: networkPath);
      expect(resolved, networkPath);
    });

    test('TC-11 & EC-01: No project open uses system default working directory fallback', () {
      final resolved = TerminalService.resolveWorkingDirectory(activeProjectPath: null, activeWorkspacePath: null);
      expect(resolved.isNotEmpty, isTrue);
    });
  });

  group('Multi-Terminal Sessions Lifecycle in WorkspaceProvider', () {
    test('TC-09: Multiple terminal sessions maintain independent state', () {
      final wp = WorkspaceProvider();
      expect(wp.terminalSessions.length, 1);
      final firstSession = wp.activeTerminalSession!;
      expect(firstSession.id, 'term-1');

      // Create second session
      final secondSession = wp.createTerminalSession();
      expect(wp.terminalSessions.length, 2);
      expect(wp.activeTerminalSessionId, secondSession.id);

      // Execute command in session 2
      wp.runTerminalCommand('echo session2');
      expect(secondSession.lines.any((l) => l.text.contains('session2')), isTrue);
      expect(firstSession.lines.any((l) => l.text.contains('session2')), isFalse);

      // Switch back to session 1
      wp.switchTerminalSession(firstSession.id);
      expect(wp.activeTerminalSessionId, firstSession.id);

      // Close session 2
      wp.closeTerminalSession(secondSession.id);
      expect(wp.terminalSessions.length, 1);
      expect(wp.activeTerminalSessionId, firstSession.id);
    });

    test('TC-10 & EC-08: Active project change keeps existing terminal paths, new terminals use new root', () {
      final wp = WorkspaceProvider();
      wp.setWorkspacePath(r'D:\Projects\ProjectA');
      final termA = wp.createTerminalSession();
      expect(termA.workingDirectory, r'D:\Projects\ProjectA');

      // Now switch active project to Project B
      wp.setWorkspacePath(r'D:\Projects\ProjectB');
      // Existing terminal A keeps Project A working directory!
      expect(termA.workingDirectory, r'D:\Projects\ProjectA');

      // Newly created terminal B uses Project B root!
      final termB = wp.createTerminalSession();
      expect(termB.workingDirectory, r'D:\Projects\ProjectB');
    });

    test('TC-16: Terminal reset / restart maintains working directory', () {
      final wp = WorkspaceProvider();
      wp.setWorkspacePath(r'C:\Users\Developer\NovaApp');
      final session = wp.createTerminalSession();
      expect(session.workingDirectory, r'C:\Users\Developer\NovaApp');

      wp.closeTerminalSession(session.id);
      // When closing the only session, it resets cleanly without crashing
      expect(wp.terminalSessions.isNotEmpty, isTrue);
    });

    test('Terminal cd and pwd commands update session working directory', () {
      final wp = WorkspaceProvider();
      final session = wp.activeTerminalSession!;
      final originalDir = session.workingDirectory;

      wp.runTerminalCommand('pwd');
      expect(session.lines.any((l) => l.text.contains(originalDir)), isTrue);

      wp.runTerminalCommand('cd subfolder');
      expect(session.workingDirectory.contains('subfolder'), isTrue);
    });
  });
}
