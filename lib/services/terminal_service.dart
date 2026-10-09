import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/platform_mode.dart';
import '../models/terminal_session.dart';
import 'platform_service.dart';

/// Centralized Terminal & Shell discovery service.
/// Detects installed shells on the host OS and resolves project root directories.
class TerminalService {
  /// Cache of detected shells to avoid repeated disk scans
  static List<ShellInfo>? _cachedShells;

  /// Detects installed and available shells for the current operating system.
  /// Unavailable shells are filtered out according to PRD US-03 and Section 9.
  static List<ShellInfo> getAvailableShells({PlatformMode? overridePlatform}) {
    final platform = overridePlatform ?? PlatformService.getCurrentPlatform();

    if (_cachedShells != null && overridePlatform == null) {
      return _cachedShells!;
    }

    final List<ShellInfo> available = [];

    switch (platform) {
      case PlatformMode.windows:
        available.addAll(_detectWindowsShells());
        break;
      case PlatformMode.mac:
        available.addAll(_detectMacShells());
        break;
      case PlatformMode.linux:
        available.addAll(_detectLinuxShells());
        break;
      case PlatformMode.android:
      case PlatformMode.ios:
      case PlatformMode.web:
        available.addAll(_detectFallbackShells(platform));
        break;
    }

    // Ensure at least one shell is marked default
    if (available.isNotEmpty && !available.any((s) => s.isDefault)) {
      final defaultShell = available.first;
      final index = available.indexOf(defaultShell);
      available[index] = ShellInfo(
        id: defaultShell.id,
        name: defaultShell.name,
        executablePath: defaultShell.executablePath,
        isAvailable: true,
        isDefault: true,
      );
    }

    final shellNames = available.map((s) => s.name).join(', ');
    debugPrint('[INFO] Available shells: $shellNames');

    if (overridePlatform == null) {
      _cachedShells = available;
    }

    return available;
  }

  /// Clears shell cache for testing or refresh
  @visibleForTesting
  static void clearCache() {
    _cachedShells = null;
  }

  static List<ShellInfo> _detectWindowsShells() {
    final List<ShellInfo> list = [];

    // 1. PowerShell
    String? psPath;
    if (!kIsWeb) {
      try {
        final sysRoot = Platform.environment['SystemRoot'] ?? 'C:\\Windows';
        final defaultPs = '$sysRoot\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
        if (File(defaultPs).existsSync()) {
          psPath = defaultPs;
        } else {
          psPath = 'powershell.exe';
        }
      } catch (_) {
        psPath = 'powershell.exe';
      }
    } else {
      psPath = 'powershell.exe';
    }

    list.add(ShellInfo(
      id: 'powershell',
      name: 'PowerShell',
      executablePath: psPath,
      isAvailable: true,
      isDefault: true,
    ));

    // 2. Command Prompt (cmd)
    String? cmdPath;
    if (!kIsWeb) {
      try {
        final comSpec = Platform.environment['COMSPEC'];
        if (comSpec != null && File(comSpec).existsSync()) {
          cmdPath = comSpec;
        } else {
          final sysRoot = Platform.environment['SystemRoot'] ?? 'C:\\Windows';
          final fallbackCmd = '$sysRoot\\System32\\cmd.exe';
          if (File(fallbackCmd).existsSync()) {
            cmdPath = fallbackCmd;
          }
        }
      } catch (_) {}
    }
    cmdPath ??= 'cmd.exe';

    list.add(ShellInfo(
      id: 'cmd',
      name: 'Command Prompt',
      executablePath: cmdPath,
      isAvailable: true,
      isDefault: false,
    ));

    // 3. Git Bash (check if installed)
    bool gitBashAvailable = false;
    String gitBashPath = 'bash.exe';
    if (!kIsWeb) {
      try {
        final candidates = [
          'C:\\Program Files\\Git\\bin\\bash.exe',
          'C:\\Program Files (x86)\\Git\\bin\\bash.exe',
          if (Platform.environment['LOCALAPPDATA'] != null)
            '${Platform.environment['LOCALAPPDATA']}\\Programs\\Git\\bin\\bash.exe',
        ];
        for (final p in candidates) {
          if (File(p).existsSync()) {
            gitBashAvailable = true;
            gitBashPath = p;
            break;
          }
        }
      } catch (_) {}
    } else {
      gitBashAvailable = true;
    }

    if (gitBashAvailable) {
      list.add(ShellInfo(
        id: 'git-bash',
        name: 'Git Bash',
        executablePath: gitBashPath,
        isAvailable: true,
        isDefault: false,
      ));
    }

    return list;
  }

  static List<ShellInfo> _detectMacShells() {
    final List<ShellInfo> list = [];

    // Zsh (macOS standard since Catalina)
    bool zshFound = true;
    String zshPath = '/bin/zsh';
    if (!kIsWeb && Platform.isMacOS) {
      try {
        if (File('/bin/zsh').existsSync()) {
          zshPath = '/bin/zsh';
        } else if (File('/usr/bin/zsh').existsSync()) {
          zshPath = '/usr/bin/zsh';
        } else {
          zshFound = false;
        }
      } catch (_) {}
    }

    if (zshFound) {
      list.add(ShellInfo(
        id: 'zsh',
        name: 'Zsh',
        executablePath: zshPath,
        isAvailable: true,
        isDefault: true,
      ));
    }

    // Bash
    bool bashFound = true;
    String bashPath = '/bin/bash';
    if (!kIsWeb && Platform.isMacOS) {
      try {
        if (File('/bin/bash').existsSync()) {
          bashPath = '/bin/bash';
        } else {
          bashFound = false;
        }
      } catch (_) {}
    }

    if (bashFound) {
      list.add(ShellInfo(
        id: 'bash',
        name: 'Bash',
        executablePath: bashPath,
        isAvailable: true,
        isDefault: !zshFound,
      ));
    }

    if (list.isEmpty) {
      list.add(const ShellInfo(
        id: 'zsh',
        name: 'Zsh',
        executablePath: '/bin/zsh',
        isAvailable: true,
        isDefault: true,
      ));
    }

    return list;
  }

  static List<ShellInfo> _detectLinuxShells() {
    final List<ShellInfo> list = [];

    // Bash (default on most Linux distros)
    bool bashFound = true;
    String bashPath = '/bin/bash';
    if (!kIsWeb) {
      try {
        if (File('/bin/bash').existsSync()) {
          bashPath = '/bin/bash';
        } else if (File('/usr/bin/bash').existsSync()) {
          bashPath = '/usr/bin/bash';
        } else {
          bashFound = false;
        }
      } catch (_) {}
    }

    if (bashFound) {
      list.add(ShellInfo(
        id: 'bash',
        name: 'Bash',
        executablePath: bashPath,
        isAvailable: true,
        isDefault: true,
      ));
    }

    // Zsh
    bool zshFound = false;
    String zshPath = '/usr/bin/zsh';
    if (!kIsWeb) {
      try {
        if (File('/usr/bin/zsh').existsSync() || File('/bin/zsh').existsSync()) {
          zshFound = true;
          zshPath = File('/usr/bin/zsh').existsSync() ? '/usr/bin/zsh' : '/bin/zsh';
        }
      } catch (_) {}
    }

    if (zshFound) {
      list.add(ShellInfo(
        id: 'zsh',
        name: 'Zsh',
        executablePath: zshPath,
        isAvailable: true,
        isDefault: false,
      ));
    }

    // Fish
    bool fishFound = false;
    String fishPath = '/usr/bin/fish';
    if (!kIsWeb) {
      try {
        if (File('/usr/bin/fish').existsSync()) {
          fishFound = true;
          fishPath = '/usr/bin/fish';
        }
      } catch (_) {}
    }

    if (fishFound) {
      list.add(ShellInfo(
        id: 'fish',
        name: 'Fish',
        executablePath: fishPath,
        isAvailable: true,
        isDefault: false,
      ));
    }

    if (list.isEmpty) {
      list.add(const ShellInfo(
        id: 'bash',
        name: 'Bash',
        executablePath: '/bin/bash',
        isAvailable: true,
        isDefault: true,
      ));
    }

    return list;
  }

  static List<ShellInfo> _detectFallbackShells(PlatformMode mode) {
    if (mode == PlatformMode.web) {
      return const [
        ShellInfo(
          id: 'mingo-sh',
          name: 'Mingo Shell (Web)',
          executablePath: 'builtin',
          isAvailable: true,
          isDefault: true,
        ),
      ];
    }
    return const [
      ShellInfo(
        id: 'sh',
        name: 'sh',
        executablePath: '/bin/sh',
        isAvailable: true,
        isDefault: true,
      ),
    ];
  }

  /// Resolves the working directory following PRD Priority (Section 19):
  /// Active Project Root -> Active Workspace Root -> Existing IDE Working Directory -> System Home Directory
  static String resolveWorkingDirectory({
    String? activeProjectPath,
    String? activeWorkspacePath,
  }) {
    // 1. Active Project Root
    if (activeProjectPath != null && activeProjectPath.trim().isNotEmpty) {
      final trimmed = activeProjectPath.trim();
      debugPrint('[INFO] Project root: $trimmed');
      return trimmed;
    }

    // 2. Active Workspace Root
    if (activeWorkspacePath != null && activeWorkspacePath.trim().isNotEmpty) {
      final trimmed = activeWorkspacePath.trim();
      return trimmed;
    }

    // 3. Existing IDE Working Directory
    if (!kIsWeb) {
      try {
        final current = Directory.current.path;
        if (current.isNotEmpty) {
          return current;
        }
      } catch (_) {}
    }

    // 4. System Home Directory
    if (!kIsWeb) {
      try {
        final home = Platform.isWindows
            ? Platform.environment['USERPROFILE']
            : Platform.environment['HOME'];
        if (home != null && home.isNotEmpty) {
          return home;
        }
      } catch (_) {}
    }

    // 5. Safe Fallback
    return PlatformService.isWindows ? 'C:\\workspace' : '/workspace';
  }
}
