import '../models/ide_types.dart';

enum TerminalSessionStatus {
  ready,
  running,
  stopped,
  error,
}

class ShellInfo {
  final String id;
  final String name;
  final String executablePath;
  final bool isAvailable;
  final bool isDefault;

  const ShellInfo({
    required this.id,
    required this.name,
    required this.executablePath,
    this.isAvailable = true,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'executablePath': executablePath,
        'isAvailable': isAvailable,
        'isDefault': isDefault,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TerminalSession {
  final String id;
  String name;
  ShellInfo shell;
  String executablePath;
  String workingDirectory;
  int? processId;
  TerminalSessionStatus status;
  dynamic currentProcess;
  final DateTime createdAt;
  final List<TerminalLine> lines;
  final List<String> history;

  TerminalSession({
    required this.id,
    required this.name,
    required this.shell,
    required this.executablePath,
    required this.workingDirectory,
    this.processId,
    this.status = TerminalSessionStatus.ready,
    this.currentProcess,
    DateTime? createdAt,
    List<TerminalLine>? lines,
    List<String>? history,
  })  : createdAt = createdAt ?? DateTime.now(),
        lines = lines ?? [],
        history = history ?? [];

  /// Generate appropriate shell prompt based on OS and current working directory
  String get prompt {
    final cleanDir = workingDirectory.replaceAll('\\', '/');
    if (shell.id == 'powershell') {
      return 'PS $workingDirectory> ';
    } else if (shell.id == 'cmd') {
      return '$workingDirectory> ';
    } else {
      // Unix-style bash/zsh/fish
      final segments = cleanDir.split('/');
      final folderName = segments.isNotEmpty && segments.last.isNotEmpty
          ? segments.last
          : cleanDir;
      return 'mingo:~/$folderName\$ ';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shell': shell.toJson(),
        'executablePath': executablePath,
        'workingDirectory': workingDirectory,
        'processId': processId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
