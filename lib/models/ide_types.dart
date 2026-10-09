enum ActivityTab {
  explorer,
  search,
  git,
  debug,
  extensions,
  ai,
  remote,
  testing,
  accounts,
  settings,
}

enum BottomPanelTab {
  terminal,
  problems,
  output,
  debugConsole,
  ports,
}

enum DiagnosticSeverity {
  error,
  warning,
  info,
}

class Diagnostic {
  final String id;
  final String file;
  final int line;
  final int col;
  final DiagnosticSeverity severity;
  final String code;
  final String message;
  final String source;

  const Diagnostic({
    required this.id,
    required this.file,
    required this.line,
    required this.col,
    required this.severity,
    required this.code,
    required this.message,
    required this.source,
  });
}

class GitCommit {
  final String id;
  final String hash;
  final String message;
  final String author;
  final String date;
  final String branch;

  const GitCommit({
    required this.id,
    required this.hash,
    required this.message,
    required this.author,
    required this.date,
    required this.branch,
  });
}

class ExtensionItem {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String version;
  final String publisher;
  final String downloads;
  final double rating;
  final String icon;
  bool installed;
  final String category;

  ExtensionItem({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.version,
    required this.publisher,
    required this.downloads,
    required this.rating,
    required this.icon,
    this.installed = false,
    required this.category,
  });
}

class RemoteTarget {
  final String id;
  final String name;
  final String type; // 'ssh', 'container', 'cloud'
  String status; // 'connected', 'disconnected', 'connecting'
  final String? ip;
  final String? latency;
  final String? specs;

  RemoteTarget({
    required this.id,
    required this.name,
    required this.type,
    this.status = 'disconnected',
    this.ip,
    this.latency,
    this.specs,
  });
}

enum TestStatus {
  passed,
  failed,
  running,
  idle,
}

class TestCase {
  final String id;
  final String name;
  final String file;
  TestStatus status;
  String? duration;
  String? errorMessage;

  TestCase({
    required this.id,
    required this.name,
    required this.file,
    this.status = TestStatus.idle,
    this.duration,
    this.errorMessage,
  });
}

class ForwardedPort {
  final int port;
  final String name;
  final String protocol;
  final String address;
  String status; // 'running', 'idle'

  ForwardedPort({
    required this.port,
    required this.name,
    required this.protocol,
    required this.address,
    this.status = 'idle',
  });
}

class CodeSnippet {
  final String language;
  final String code;
  final String? filePath;

  const CodeSnippet({
    required this.language,
    required this.code,
    this.filePath,
  });
}

class AgentStep {
  final int step;
  final String description;
  String status; // 'pending', 'running', 'completed', 'failed'
  final String actionType; // 'create_file', 'edit_file', 'run_command', 'test'
  final String? target;

  AgentStep({
    required this.step,
    required this.description,
    this.status = 'pending',
    required this.actionType,
    this.target,
  });
}

class PermissionRequest {
  final String action;
  final String commandOrFile;
  final bool requiresConfirm;

  const PermissionRequest({
    required this.action,
    required this.commandOrFile,
    this.requiresConfirm = true,
  });
}

class AIChatMessage {
  final String id;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String timestamp;
  final String? model;
  final CodeSnippet? codeSnippet;
  final List<AgentStep>? agentSteps;
  final PermissionRequest? permissionRequest;

  AIChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.model,
    this.codeSnippet,
    this.agentSteps,
    this.permissionRequest,
  });
}

class TerminalLine {
  final String text;
  final String type; // 'info', 'error', 'success', 'cmd'

  const TerminalLine({
    required this.text,
    this.type = 'info',
  });
}
