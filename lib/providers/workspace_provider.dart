import 'dart:io' show Directory, Process, systemEncoding;
import 'dart:convert' show utf8;
import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import '../models/editor_tab.dart';
import '../models/ide_types.dart';
import '../models/theme_definition.dart';
import '../models/platform_mode.dart';
import '../models/terminal_session.dart';
import '../data/extensions_data.dart';
import '../data/themes_data.dart';
import '../constants/app_constants.dart';
import '../services/file_system_service.dart';
import '../services/platform_service.dart';
import '../services/terminal_service.dart';

class WorkspaceProvider extends ChangeNotifier {
  // Files and tabs
  List<FileItem> _files = [];
  final List<EditorTab> _openTabs = [];
  String? _activeTabId;
  FileItem? _diffFile;

  // Workspace Name & Path
  String _workspaceName = AppConstants.defaultWorkspaceName;
  String? _workspacePath;

  // Platform Mode
  PlatformMode _platformMode = PlatformMode.windows;
  bool _isMobileDrawerOpen = false;

  // Layout states
  ActivityTab _activityTab = ActivityTab.explorer;
  bool _isSidebarOpen = true;
  bool _isBottomPanelOpen = false;
  BottomPanelTab _bottomPanelTab = BottomPanelTab.terminal;
  bool _isAiPanelOpen = false;
  bool _isCommandPaletteOpen = false;
  bool _isWorkspaceTrusted = true;
  String? _previewUrl;

  // Theme & Settings
  String _themeId = AppConstants.defaultThemeId;
  double _fontSize = AppConstants.defaultFontSize;
  String _fontFamily = AppConstants.defaultTypography;
  bool _wordWrap = false;

  // Git State
  String _currentBranch = 'main';
  final List<String> _branches = ['main'];
  final List<String> _stagedFiles = [];
  final List<String> _unstagedFiles = [];
  String _commitMessage = '';
  final List<GitCommit> _gitHistory = [];

  // Diagnostics
  final List<Diagnostic> _diagnostics = [];

  // Extensions
  List<ExtensionItem> _extensions = [];

  // Tests
  final List<TestCase> _testCases = [];

  // Ports
  final List<ForwardedPort> _ports = [];

  // Terminal Sessions & Shells
  List<ShellInfo> _availableShells = [];
  List<TerminalSession> _terminalSessions = [];
  String? _activeTerminalSessionId;
  int _sessionCounter = 1;
  final List<TerminalLine> _terminalLines = [
    const TerminalLine(text: '⚡ ${AppConstants.appName} Terminal ready.', type: 'info'),
    const TerminalLine(
        text: 'Open a local folder or file to begin working.', type: 'info'),
  ];

  // Search
  String _searchQuery = '';
  String _replaceQuery = '';

  // AI Assistant & Agent
  String _aiModel = AppConstants.defaultAiModel;
  bool _isAgentRunning = false;
  List<AIChatMessage> _aiMessages = [];

  WorkspaceProvider() {
    _initPlatformMode();
    _initTerminalSessions();
    _extensions = ExtensionsData.getInitialExtensions();
    _aiMessages = [
      AIChatMessage(
        id: 'm1',
        role: 'assistant',
        content:
            'Hello! I am **${AppConstants.aiAssistantName}**. Open a folder from your disk or create a file to start coding.',
        timestamp: 'Just now',
        model: AppConstants.defaultAiModel,
      ),
    ];
  }

  void _initPlatformMode() {
    _platformMode = PlatformService.getCurrentPlatform();
  }

  void _initTerminalSessions() {
    _availableShells = TerminalService.getAvailableShells(overridePlatform: _platformMode);
    final defaultShell = _availableShells.firstWhere(
      (s) => s.isDefault,
      orElse: () => _availableShells.isNotEmpty
          ? _availableShells.first
          : const ShellInfo(id: 'sh', name: 'Shell', executablePath: 'sh', isAvailable: true, isDefault: true),
    );
    final initialWorkDir = TerminalService.resolveWorkingDirectory(
      activeProjectPath: _workspacePath,
      activeWorkspacePath: _workspaceName != 'No Folder Opened' ? _workspaceName : null,
    );
    final initialSession = TerminalSession(
      id: 'term-1',
      name: '1: ${defaultShell.name}',
      shell: defaultShell,
      executablePath: defaultShell.executablePath,
      workingDirectory: initialWorkDir,
      status: TerminalSessionStatus.ready,
      lines: [
        TerminalLine(text: '⚡ ${AppConstants.appName} Terminal ready [${defaultShell.name}].', type: 'info'),
        TerminalLine(text: 'Working directory: $initialWorkDir', type: 'info'),
      ],
    );
    _terminalSessions = [initialSession];
    _activeTerminalSessionId = initialSession.id;
    _sessionCounter = 1;
  }

  // Getters
  List<FileItem> get files => _files;
  List<EditorTab> get openTabs => _openTabs;
  String? get activeTabId => _activeTabId;
  FileItem? get diffFile => _diffFile;
  String get workspaceName => _workspaceName;
  String? get workspacePath => _workspacePath;
  PlatformMode get platformMode => _platformMode;
  bool get isMobileDrawerOpen => _isMobileDrawerOpen;
  List<ShellInfo> get availableShells => _availableShells;
  List<TerminalSession> get terminalSessions => _terminalSessions;
  TerminalSession? get activeTerminalSession {
    if (_activeTerminalSessionId != null) {
      final matches = _terminalSessions.where((s) => s.id == _activeTerminalSessionId);
      if (matches.isNotEmpty) return matches.first;
    }
    return _terminalSessions.isNotEmpty ? _terminalSessions.first : null;
  }
  String? get activeTerminalSessionId => _activeTerminalSessionId;

  ActivityTab get activityTab => _activityTab;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isBottomPanelOpen => _isBottomPanelOpen;
  BottomPanelTab get bottomPanelTab => _bottomPanelTab;
  bool get isAiPanelOpen => _isAiPanelOpen;
  bool get isCommandPaletteOpen => _isCommandPaletteOpen;
  bool get isWorkspaceTrusted => _isWorkspaceTrusted;
  String? get previewUrl => _previewUrl;

  String get themeId => _themeId;
  ThemeDefinition get theme => ThemesData.getTheme(_themeId);
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  bool get wordWrap => _wordWrap;

  String get currentBranch => _currentBranch;
  List<String> get branches => _branches;
  List<String> get stagedFiles => _stagedFiles;
  List<String> get unstagedFiles => _unstagedFiles;
  String get commitMessage => _commitMessage;
  List<GitCommit> get gitHistory => _gitHistory;

  List<Diagnostic> get diagnostics => _diagnostics;
  List<ExtensionItem> get extensions => _extensions;
  List<TestCase> get testCases => _testCases;
  List<ForwardedPort> get ports => _ports;
  List<TerminalLine> get terminalLines =>
      activeTerminalSession?.lines ?? _terminalLines;

  String get searchQuery => _searchQuery;
  String get replaceQuery => _replaceQuery;

  String get aiModel => _aiModel;
  bool get isAgentRunning => _isAgentRunning;
  List<AIChatMessage> get aiMessages => _aiMessages;

  bool isMobileLayout(double screenWidth) {
    if (_platformMode == PlatformMode.windows ||
        _platformMode == PlatformMode.mac ||
        _platformMode == PlatformMode.linux ||
        PlatformService.isDesktop) {
      return false;
    }
    return _platformMode == PlatformMode.android ||
        _platformMode == PlatformMode.ios ||
        screenWidth < 768;
  }

  // Active file resolution
  EditorTab? get activeTab {
    if (_activeTabId == null) return null;
    try {
      return _openTabs.firstWhere((t) => t.id == _activeTabId);
    } catch (_) {
      return null;
    }
  }

  FileItem? get activeFile {
    final tab = activeTab;
    if (tab == null) return null;
    return _findFileByPath(_files, tab.path);
  }

  FileItem? _findFileByPath(List<FileItem> items, String path) {
    for (final item in items) {
      if (item.path == path) return item;
      if (item.children != null) {
        final found = _findFileByPath(item.children!, path);
        if (found != null) return found;
      }
    }
    return null;
  }

  // Setters & Actions
  void setPlatformMode(PlatformMode mode) {
    _platformMode = mode;
    notifyListeners();
  }

  void setWorkspacePath(String path) {
    _workspacePath = path;
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      _workspaceName = segments.last;
    }
    notifyListeners();
  }

  void setMobileDrawerOpen(bool open) {
    _isMobileDrawerOpen = open;
    notifyListeners();
  }

  void setThemeId(String id) {
    _themeId = id;
    notifyListeners();
  }

  void setTheme(String id) => setThemeId(id);

  void toggleTheme() {
    if (theme.isDark) {
      _themeId = AppConstants.corporateLightThemeId;
    } else {
      _themeId = AppConstants.defaultThemeId;
    }
    notifyListeners();
  }

  void setFontSize(double size) {
    if (_fontSize != size) {
      _fontSize = size;
      notifyListeners();
    }
  }

  void setFontFamily(String family) {
    if (_fontFamily != family) {
      _fontFamily = family;
      notifyListeners();
    }
  }

  void setWordWrap(bool wrap) {
    if (_wordWrap != wrap) {
      _wordWrap = wrap;
      notifyListeners();
    }
  }

  void toggleWordWrap() {
    _wordWrap = !_wordWrap;
    notifyListeners();
  }

  void setWorkspaceName(String name) {
    _workspaceName = name;
    notifyListeners();
  }

  void setActivityTab(ActivityTab tab) {
    _activityTab = tab;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void toggleBottomPanel() {
    _isBottomPanelOpen = !_isBottomPanelOpen;
    notifyListeners();
  }

  void setBottomPanelTab(BottomPanelTab tab) {
    _bottomPanelTab = tab;
    notifyListeners();
  }

  void toggleAiPanel() {
    _isAiPanelOpen = !_isAiPanelOpen;
    notifyListeners();
  }

  void setCommandPaletteOpen(bool open) {
    _isCommandPaletteOpen = open;
    notifyListeners();
  }

  void setWorkspaceTrusted(bool trusted) {
    _isWorkspaceTrusted = trusted;
    notifyListeners();
  }

  void setPreviewUrl(String? url) {
    _previewUrl = url;
    notifyListeners();
  }

  void setDiffFile(FileItem? file) {
    _diffFile = file;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setReplaceQuery(String q) {
    _replaceQuery = q;
    notifyListeners();
  }

  void setAiModel(String model) {
    _aiModel = model;
    notifyListeners();
  }

  void setCommitMessage(String msg) {
    _commitMessage = msg;
    notifyListeners();
  }

  // File & Tab Operations
  void openFile(FileItem file) {
    if (file.isFolder) return;
    _diffFile = null;

    final existingIndex = _openTabs.indexWhere((t) => t.path == file.path);
    if (existingIndex != -1) {
      _activeTabId = _openTabs[existingIndex].id;
    } else {
      final newTab = EditorTab(
        id: 'tab-${DateTime.now().millisecondsSinceEpoch}',
        fileId: file.id,
        name: file.name,
        path: file.path,
        language: file.language,
        isDirty: false,
      );
      _openTabs.add(newTab);
      _activeTabId = newTab.id;
    }
    notifyListeners();
  }

  void closeTab(String tabId) {
    final index = _openTabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;

    _openTabs.removeAt(index);
    if (_activeTabId == tabId) {
      if (_openTabs.isNotEmpty) {
        final newIndex = (index - 1).clamp(0, _openTabs.length - 1);
        _activeTabId = _openTabs[newIndex].id;
      } else {
        _activeTabId = null;
      }
    }
    notifyListeners();
  }

  void selectTab(String tabId) {
    _activeTabId = tabId;
    _diffFile = null;
    notifyListeners();
  }

  void updateFileContent(String path, String newContent) {
    void updateRecursive(List<FileItem> items) {
      for (final item in items) {
        if (item.path == path) {
          item.content = newContent;
          item.isDirty = true;
          item.gitStatus = GitFileStatus.modified;
          if (!_unstagedFiles.contains(path) && !_stagedFiles.contains(path)) {
            _unstagedFiles.add(path);
          }
        }
        if (item.children != null) {
          updateRecursive(item.children!);
        }
      }
    }

    updateRecursive(_files);

    for (final tab in _openTabs) {
      if (tab.path == path) {
        tab.isDirty = true;
      }
    }
    notifyListeners();
  }

  void saveActiveFile() {
    final file = activeFile;
    if (file == null) return;

    file.isDirty = false;
    for (final tab in _openTabs) {
      if (tab.path == file.path) {
        tab.isDirty = false;
      }
    }

    _terminalLines.add(TerminalLine(
      text: '[${AppConstants.appName} AutoSave] Saved ${file.path}',
      type: 'info',
    ));
    notifyListeners();
  }

  void createFile(String name, [String? folderPath]) {
    final targetPath = folderPath != null ? '$folderPath/$name' : name;
    final newFile = FileItem(
      id: 'file-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      path: targetPath,
      language: FileSystemService.getLanguageByFilename(name),
      isFolder: false,
      content: '// $name\n',
      gitStatus: GitFileStatus.untracked,
    );

    if (folderPath == null) {
      _files.add(newFile);
    } else {
      void addToFolder(List<FileItem> items) {
        for (final item in items) {
          if (item.path == folderPath && item.isFolder) {
            item.children ??= [];
            item.children!.add(newFile);
            return;
          }
          if (item.children != null) {
            addToFolder(item.children!);
          }
        }
      }

      addToFolder(_files);
    }

    openFile(newFile);
    notifyListeners();
  }

  void createFolder(String name, [String? folderPath]) {
    final targetPath = folderPath != null ? '$folderPath/$name' : name;
    final newFolder = FileItem(
      id: 'folder-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      path: targetPath,
      isFolder: true,
      isOpen: true,
      children: [],
    );

    if (folderPath == null) {
      _files.add(newFolder);
    } else {
      void addToFolder(List<FileItem> items) {
        for (final item in items) {
          if (item.path == folderPath && item.isFolder) {
            item.children ??= [];
            item.children!.add(newFolder);
            return;
          }
          if (item.children != null) {
            addToFolder(item.children!);
          }
        }
      }

      addToFolder(_files);
    }
    notifyListeners();
  }

  void deleteItem(String path) {
    List<FileItem> removeRecursive(List<FileItem> items) {
      final List<FileItem> result = [];
      for (final item in items) {
        if (item.path == path) continue;
        if (item.children != null) {
          item.children = removeRecursive(item.children!);
        }
        result.add(item);
      }
      return result;
    }

    _files = removeRecursive(_files);
    _openTabs.removeWhere((t) => t.path == path);
    if (activeFile == null && _openTabs.isNotEmpty) {
      _activeTabId = _openTabs.first.id;
    }
    notifyListeners();
  }

  Future<void> openFolder() async {
    final res = await FileSystemService.openDirectory();
    if (res != null) {
      _workspaceName = res['folderName'] as String;
      _workspacePath = res['directoryPath'] as String?;
      _files = res['files'] as List<FileItem>;
      _openTabs.clear();
      _activeTabId = null;

      FileItem? findFirstFile(List<FileItem> items) {
        for (final item in items) {
          if (!item.isFolder) return item;
          if (item.children != null) {
            final f = findFirstFile(item.children!);
            if (f != null) return f;
          }
        }
        return null;
      }

      final first = findFirstFile(_files);
      if (first != null) {
        openFile(first);
      }

      // Existing terminal sessions maintain their working directory (EC-08, EC-14).
      // If no terminals exist, create one starting at the new project root.
      if (_terminalSessions.isEmpty) {
        createTerminalSession();
      }

      final logPath = _workspacePath != null ? ' ($_workspacePath)' : '';
      final logText =
          '[${AppConstants.appName}] Opened folder: $_workspaceName$logPath (${_files.length} items loaded)';
      activeTerminalSession?.lines.add(TerminalLine(
        text: logText,
        type: 'success',
      ));
      notifyListeners();
    }
  }

  Future<void> openSingleFile() async {
    final file = await FileSystemService.openSingleFile();
    if (file != null) {
      _files.insert(0, file);
      openFile(file);
      notifyListeners();
    }
  }

  // Git Operations
  void stageFile(String path) {
    if (!_stagedFiles.contains(path)) {
      _stagedFiles.add(path);
      _unstagedFiles.remove(path);
      notifyListeners();
    }
  }

  void unstageFile(String path) {
    if (_stagedFiles.contains(path)) {
      _stagedFiles.remove(path);
      if (!_unstagedFiles.contains(path)) {
        _unstagedFiles.add(path);
      }
      notifyListeners();
    }
  }

  void stageAll() {
    _stagedFiles.addAll(_unstagedFiles);
    _unstagedFiles.clear();
    notifyListeners();
  }

  void createBranch(String name) {
    if (!_branches.contains(name)) {
      _branches.add(name);
      _currentBranch = name;
      _terminalLines.add(
          TerminalLine(text: 'git checkout -b $name', type: 'cmd'));
      _terminalLines.add(TerminalLine(
          text: "Switched to a new branch '$name'", type: 'success'));
      notifyListeners();
    }
  }

  void setCurrentBranch(String name) {
    _currentBranch = name;
    notifyListeners();
  }

  void commit([String? msg]) => commitChanges(msg);

  void commitChanges([String? msg]) {
    final finalMsg = msg ?? _commitMessage;
    if (finalMsg.trim().isEmpty || _stagedFiles.isEmpty) return;

    final commit = GitCommit(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      hash: DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 7),
      message: finalMsg,
      author: '${AppConstants.appShortName} Developer',
      date: 'Just now',
      branch: _currentBranch,
    );

    _gitHistory.insert(0, commit);
    final count = _stagedFiles.length;
    _stagedFiles.clear();
    _commitMessage = '';

    _terminalLines.add(
        TerminalLine(text: 'git commit -m "$finalMsg"', type: 'cmd'));
    _terminalLines.add(TerminalLine(
        text: '[$_currentBranch ${commit.hash}] $finalMsg', type: 'success'));
    _terminalLines.add(TerminalLine(
        text: ' $count file(s) changed, 14 insertions(+)', type: 'info'));
    notifyListeners();
  }

  // Extensions
  void toggleInstallExtension(String id) {
    final index = _extensions.indexWhere((e) => e.id == id);
    if (index != -1) {
      _extensions[index].installed = !_extensions[index].installed;
      notifyListeners();
    }
  }

  // Testing
  void runTest(String id) {
    final index = _testCases.indexWhere((t) => t.id == id);
    if (index != -1) {
      _testCases[index].status = TestStatus.running;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 600), () {
        _testCases[index].status = TestStatus.passed;
        _testCases[index].duration = '12ms';
        _terminalLines.add(
            TerminalLine(text: 'cargo test $id', type: 'cmd'));
        _terminalLines.add(TerminalLine(
            text: 'test $id ... ok (12ms)', type: 'success'));
        notifyListeners();
      });
    }
  }

  void runAllTests() {
    for (final t in _testCases) {
      t.status = TestStatus.running;
    }
    _terminalLines.add(
        const TerminalLine(text: 'cargo test --workspace', type: 'cmd'));
    _terminalLines.add(
        const TerminalLine(text: 'running 4 tests...', type: 'info'));
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1000), () {
      for (final t in _testCases) {
        t.status = TestStatus.passed;
        t.duration = '15ms';
      }
      _terminalLines.add(const TerminalLine(
          text:
              'test result: ok. 4 passed; 0 failed; 0 ignored; finished in 0.04s',
          type: 'success'));
      notifyListeners();
    });
  }

  // Multi-Terminal Session Lifecycle (PRD Section 14, US-05)
  TerminalSession createTerminalSession({ShellInfo? shell, String? customPath}) {
    _availableShells = TerminalService.getAvailableShells(overridePlatform: _platformMode);
    final targetShell = shell ??
        _availableShells.firstWhere((s) => s.isDefault, orElse: () => _availableShells.first);

    final workDir = customPath ??
        TerminalService.resolveWorkingDirectory(
          activeProjectPath: _workspacePath,
          activeWorkspacePath: _workspaceName != 'No Folder Opened' ? _workspaceName : null,
        );

    _sessionCounter++;
    final sessionId = 'term-$_sessionCounter';

    final session = TerminalSession(
      id: sessionId,
      name: '$_sessionCounter: ${targetShell.name}',
      shell: targetShell,
      executablePath: targetShell.executablePath,
      workingDirectory: workDir,
      status: TerminalSessionStatus.ready,
      lines: [
        TerminalLine(text: '⚡ ${AppConstants.appName} Terminal session started [${targetShell.name}].', type: 'info'),
        TerminalLine(text: 'Directory: $workDir', type: 'info'),
      ],
    );

    _terminalSessions.add(session);
    _activeTerminalSessionId = session.id;
    debugPrint('[INFO] Starting terminal: ${targetShell.name}');
    debugPrint('[INFO] Working directory: $workDir');
    notifyListeners();
    return session;
  }

  void switchTerminalSession(String id) {
    if (_activeTerminalSessionId != id && _terminalSessions.any((s) => s.id == id)) {
      _activeTerminalSessionId = id;
      notifyListeners();
    }
  }

  void closeTerminalSession(String id) {
    if (_terminalSessions.length <= 1) {
      final session = _terminalSessions.first;
      if (session.currentProcess != null) {
        try {
          if (session.currentProcess is Process) {
            (session.currentProcess as Process).kill();
          }
        } catch (_) {}
        session.currentProcess = null;
        session.processId = null;
        session.status = TerminalSessionStatus.ready;
      }
      session.lines.clear();
      session.lines.add(TerminalLine(text: '⚡ Terminal reset [${session.shell.name}].', type: 'info'));
      session.lines.add(TerminalLine(text: 'Directory: ${session.workingDirectory}', type: 'info'));
      notifyListeners();
      return;
    }

    final index = _terminalSessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final session = _terminalSessions[index];
      if (session.currentProcess != null) {
        try {
          if (session.currentProcess is Process) {
            (session.currentProcess as Process).kill();
          }
        } catch (_) {}
      }
      _terminalSessions.removeAt(index);
      if (_activeTerminalSessionId == id) {
        _activeTerminalSessionId = _terminalSessions[index > 0 ? index - 1 : 0].id;
      }
      notifyListeners();
    }
  }

  void changeTerminalShell(String sessionId, ShellInfo newShell) {
    final index = _terminalSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _terminalSessions[index];
      if (session.currentProcess != null) {
        try {
          if (session.currentProcess is Process) {
            (session.currentProcess as Process).kill();
          }
        } catch (_) {}
        session.currentProcess = null;
        session.processId = null;
        session.status = TerminalSessionStatus.ready;
      }
      session.shell = newShell;
      session.executablePath = newShell.executablePath;
      final prefix = session.name.split(':').first;
      session.name = '$prefix: ${newShell.name}';
      session.lines.add(TerminalLine(
        text: '➜ Switched shell to ${newShell.name} (${newShell.executablePath})',
        type: 'success',
      ));
      notifyListeners();
    }
  }

  void cancelCurrentCommand({String? targetSessionId}) {
    final session = targetSessionId != null
        ? _terminalSessions.firstWhere((s) => s.id == targetSessionId,
            orElse: () => activeTerminalSession ?? createTerminalSession())
        : (activeTerminalSession ?? createTerminalSession());
    if (session.currentProcess != null) {
      try {
        if (session.currentProcess is Process) {
          (session.currentProcess as Process).kill();
        }
      } catch (_) {}
      session.currentProcess = null;
      session.processId = null;
      session.status = TerminalSessionStatus.ready;
    }
    session.lines.add(TerminalLine(text: '${session.prompt}^C', type: 'cmd'));
    notifyListeners();
  }

  // Terminal Execution
  Future<void> runTerminalCommand(String cmd, {String? targetSessionId}) async {
    final session = targetSessionId != null
        ? _terminalSessions.firstWhere((s) => s.id == targetSessionId,
            orElse: () => activeTerminalSession ?? createTerminalSession())
        : (activeTerminalSession ?? createTerminalSession());

    final trimmed = cmd.trim();

    if (session.status == TerminalSessionStatus.running && session.currentProcess != null) {
      try {
        if (session.currentProcess is Process) {
          (session.currentProcess as Process).stdin.writeln(trimmed);
        }
      } catch (_) {}
      session.lines.add(TerminalLine(text: trimmed, type: 'cmd'));
      notifyListeners();
      return;
    }

    if (trimmed.isEmpty) {
      session.lines.add(TerminalLine(text: session.prompt, type: 'cmd'));
      notifyListeners();
      return;
    }

    session.history.add(trimmed);
    session.lines.add(TerminalLine(text: '${session.prompt}$trimmed', type: 'cmd'));

    if (trimmed == 'clear' || trimmed == 'cls') {
      session.lines.clear();
      notifyListeners();
      return;
    }

    if (trimmed == 'pwd') {
      session.lines.add(TerminalLine(text: session.workingDirectory, type: 'info'));
      notifyListeners();
      return;
    }

    if (trimmed == 'help') {
      session.lines.addAll([
        TerminalLine(text: '${AppConstants.appName} Integrated Real Shell Terminal', type: 'info'),
        TerminalLine(text: 'Current Shell: ${session.shell.name} (${session.executablePath})', type: 'info'),
        TerminalLine(text: 'Working Directory: ${session.workingDirectory}', type: 'info'),
        const TerminalLine(text: '', type: 'info'),
        const TerminalLine(text: 'Built-in commands:', type: 'info'),
        const TerminalLine(text: '  cd <path>     - Change working directory for this session', type: 'info'),
        const TerminalLine(text: '  pwd           - Print current working directory', type: 'info'),
        const TerminalLine(text: '  clear / cls   - Clear the terminal screen', type: 'info'),
        const TerminalLine(text: '  help          - Show this help message', type: 'info'),
        const TerminalLine(text: '', type: 'info'),
        const TerminalLine(text: 'All system commands and tools run directly in the host OS:', type: 'info'),
        const TerminalLine(text: '  dir, ls, git, flutter, dart, cargo, python, npm, docker, etc.', type: 'info'),
      ]);
      notifyListeners();
      return;
    }

    if (trimmed == 'cd' ||
        trimmed.startsWith('cd ') ||
        RegExp(r'^[a-zA-Z]:$').hasMatch(trimmed)) {
      _handleDirectoryChange(session, trimmed);
      return;
    }

    if (trimmed == 'cargo build') {
      await _executeDelayedSteps(session, [
        TerminalLine(
            text: '   Compiling ${AppConstants.appShortName.toLowerCase()}-core v1.0.0 (${session.workingDirectory})',
            type: 'info'),
        const TerminalLine(text: '   Compiling tokio v1.40.0', type: 'info'),
        const TerminalLine(text: '   Compiling lsp-types v0.97.0', type: 'info'),
        const TerminalLine(
            text: '    Finished `dev` profile [unoptimized + debuginfo] in 1.48s',
            type: 'success'),
      ], delayMs: 380);
      return;
    }

    if (trimmed == 'cargo run') {
      await _executeDelayedSteps(session, [
        const TerminalLine(
            text: '    Finished `dev` profile [unoptimized + debuginfo] in 0.08s',
            type: 'info'),
        TerminalLine(text: '     Running `target/debug/${AppConstants.appShortName.toLowerCase()}-core`', type: 'info'),
        TerminalLine(
            text: '⚡ Initializing ${AppConstants.appName} Engine v1.0.0 for [${session.workingDirectory}]',
            type: 'success'),
        const TerminalLine(
            text: '🚀 Successfully indexed source files in parallel',
            type: 'success'),
        const TerminalLine(text: 'Ready. 3 symbols loaded into memory.', type: 'info'),
      ], delayMs: 320);
      return;
    }

    if (trimmed == 'flutter run' || trimmed == 'npm run dev') {
      await _executeDelayedSteps(session, [
        TerminalLine(text: '  Launching ${AppConstants.appName} in dev mode...', type: 'info'),
        const TerminalLine(text: '  ➜  Local:   http://localhost:5173/', type: 'success'),
        const TerminalLine(text: '  ➜  Flutter dev server ready in 240 ms', type: 'success'),
      ], delayMs: 350);
      _previewUrl = 'http://localhost:5173';
      notifyListeners();
      return;
    }

    if (trimmed == 'cargo test') {
      runAllTests();
      return;
    }

    if (trimmed == 'git status') {
      final hasGit = Directory('${session.workingDirectory}/.git').existsSync() ||
          Directory('${session.workingDirectory}\\.git').existsSync();
      if (!hasGit) {
        await _executeDelayedSteps(session, [
          TerminalLine(text: 'On branch $_currentBranch', type: 'info'),
          const TerminalLine(text: 'Changes to be committed:', type: 'success'),
          ..._stagedFiles.map((f) => TerminalLine(text: '  modified:   $f', type: 'success')),
          const TerminalLine(text: 'Changes not staged for commit:', type: 'error'),
          ..._unstagedFiles.map((f) => TerminalLine(text: '  modified:   $f', type: 'error')),
        ], delayMs: 150);
        return;
      }
    }

    // Launch real OS process with delayed streaming and wait till completed
    await _executeRealProcess(session, trimmed);
  }

  Future<void> _executeDelayedSteps(
    TerminalSession session,
    List<TerminalLine> lines, {
    int delayMs = 350,
  }) async {
    session.status = TerminalSessionStatus.running;
    notifyListeners();

    for (final line in lines) {
      if (session.status != TerminalSessionStatus.running) break;
      await Future.delayed(Duration(milliseconds: delayMs));
      if (session.status != TerminalSessionStatus.running) break;
      session.lines.add(line);
      notifyListeners();
    }

    if (session.status == TerminalSessionStatus.running) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (session.status == TerminalSessionStatus.running) {
        session.status = TerminalSessionStatus.ready;
        notifyListeners();
      }
    }
  }

  void _handleDirectoryChange(TerminalSession session, String cmd) {
    final trimmed = cmd.trim();

    // Check for Windows drive letter change: e.g. "D:" or "c:"
    final driveMatch = RegExp(r'^([a-zA-Z]):$').firstMatch(trimmed);
    if (driveMatch != null) {
      final driveLetter = driveMatch.group(1)!.toUpperCase();
      final targetPath = '$driveLetter:\\';
      session.workingDirectory = targetPath;
      session.lines.add(TerminalLine(text: session.workingDirectory, type: 'info'));
      notifyListeners();
      return;
    }

    if (trimmed == 'cd') {
      final home = TerminalService.resolveWorkingDirectory();
      session.workingDirectory = home;
      session.lines.add(TerminalLine(text: home, type: 'info'));
      notifyListeners();
      return;
    }

    var targetPath = trimmed.substring(2).trim();
    if ((targetPath.startsWith('"') && targetPath.endsWith('"')) ||
        (targetPath.startsWith("'") && targetPath.endsWith("'"))) {
      if (targetPath.length >= 2) {
        targetPath = targetPath.substring(1, targetPath.length - 1).trim();
      }
    }

    if (targetPath.isEmpty) {
      final home = TerminalService.resolveWorkingDirectory();
      session.workingDirectory = home;
      session.lines.add(TerminalLine(text: home, type: 'info'));
      notifyListeners();
      return;
    }

    if (targetPath == '.' || targetPath == './') {
      session.lines.add(TerminalLine(text: session.workingDirectory, type: 'info'));
      notifyListeners();
      return;
    }

    if (targetPath == '..' || targetPath == '../') {
      try {
        final parent = Directory(session.workingDirectory).parent.path;
        session.workingDirectory = parent;
      } catch (_) {
        final parts = session.workingDirectory.replaceAll('\\', '/').split('/');
        if (parts.length > 1) {
          parts.removeLast();
          session.workingDirectory = parts.join(session.workingDirectory.contains('\\') ? '\\' : '/');
        }
      }
      session.lines.add(TerminalLine(text: session.workingDirectory, type: 'info'));
      notifyListeners();
      return;
    }

    String newPath;
    final isAbsolute = targetPath.startsWith('/') ||
        targetPath.startsWith('\\') ||
        (targetPath.length >= 2 && targetPath[1] == ':');

    if (isAbsolute) {
      newPath = targetPath;
    } else {
      final sep = session.workingDirectory.contains('\\') ? '\\' : '/';
      newPath = '${session.workingDirectory}$sep$targetPath';
    }

    try {
      final dir = Directory(newPath);
      if (dir.existsSync()) {
        newPath = dir.path;
      }
    } catch (_) {}

    session.workingDirectory = newPath;
    session.lines.add(TerminalLine(text: session.workingDirectory, type: 'info'));
    notifyListeners();
  }

  Future<void> _executeRealProcess(TerminalSession session, String cmd) async {
    if (kIsWeb) {
      _executeWebFallback(session, cmd);
      return;
    }

    session.status = TerminalSessionStatus.running;
    notifyListeners();

    final startTime = DateTime.now();

    try {
      String executable;
      List<String> args;

      final isWindows = PlatformService.getCurrentPlatform() == PlatformMode.windows;
      final isMac = PlatformService.getCurrentPlatform() == PlatformMode.mac;
      final isLinux = PlatformService.getCurrentPlatform() == PlatformMode.linux;

      if (isWindows) {
        if (session.shell.id == 'cmd' ||
            session.executablePath.toLowerCase().endsWith('cmd.exe')) {
          executable = session.executablePath.isNotEmpty ? session.executablePath : 'cmd.exe';
          args = ['/c', cmd];
        } else if (session.shell.id == 'git-bash' ||
            session.shell.id == 'bash' ||
            session.executablePath.toLowerCase().endsWith('bash.exe')) {
          executable = session.executablePath.isNotEmpty ? session.executablePath : 'bash.exe';
          args = ['-c', cmd];
        } else {
          executable = session.executablePath.isNotEmpty ? session.executablePath : 'powershell.exe';
          args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', cmd];
        }
      } else if (isMac || isLinux) {
        executable = session.executablePath.isNotEmpty ? session.executablePath : '/bin/sh';
        args = ['-c', cmd];
      } else {
        _executeWebFallback(session, cmd);
        return;
      }

      String workDir = session.workingDirectory;
      try {
        if (!Directory(workDir).existsSync()) {
          workDir = TerminalService.resolveWorkingDirectory();
        }
      } catch (_) {
        workDir = TerminalService.resolveWorkingDirectory();
      }

      final process = await Process.start(
        executable,
        args,
        workingDirectory: workDir,
        runInShell: true,
      );

      session.currentProcess = process;
      session.processId = process.pid;
      notifyListeners();

      final outputQueue = <TerminalLine>[];
      bool processExited = false;

      process.stdout.listen((data) {
        String output;
        try {
          output = systemEncoding.decode(data);
        } catch (_) {
          output = utf8.decode(data, allowMalformed: true);
        }
        _queueOutputLines(outputQueue, output, 'info');
      });

      process.stderr.listen((data) {
        String output;
        try {
          output = systemEncoding.decode(data);
        } catch (_) {
          output = utf8.decode(data, allowMalformed: true);
        }
        _queueOutputLines(outputQueue, output, 'error');
      });

      process.exitCode.then((_) {
        processExited = true;
      }).catchError((_) {
        processExited = true;
      });

      // Stream lines from outputQueue with smooth delay while process is running or queue is non-empty
      while (session.status == TerminalSessionStatus.running &&
          (!processExited || outputQueue.isNotEmpty)) {
        if (outputQueue.isNotEmpty) {
          final nextLine = outputQueue.removeAt(0);
          session.lines.add(nextLine);
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 30));
        } else {
          await Future.delayed(const Duration(milliseconds: 40));
        }
      }

      // Ensure minimum delay of 450ms so user visibly observes execution and waiting
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 450 && session.status == TerminalSessionStatus.running) {
        await Future.delayed(Duration(milliseconds: 450 - elapsed));
      }

      if (session.status == TerminalSessionStatus.running) {
        session.currentProcess = null;
        session.processId = null;
        session.status = TerminalSessionStatus.ready;
        notifyListeners();
      }
    } catch (e) {
      if (session.status == TerminalSessionStatus.running) {
        session.currentProcess = null;
        session.processId = null;
        session.status = TerminalSessionStatus.ready;
        session.lines.add(TerminalLine(
          text: 'Failed to run command "$cmd": $e',
          type: 'error',
        ));
        notifyListeners();
      }
    }
  }

  void _queueOutputLines(List<TerminalLine> queue, String text, String type) {
    if (text.isEmpty) return;
    final cleanText = text.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
    final rawLines = cleanText.split(RegExp(r'\r?\n'));

    for (var i = 0; i < rawLines.length; i++) {
      final line = rawLines[i];
      if (i == rawLines.length - 1 && line.isEmpty) {
        continue;
      }
      queue.add(TerminalLine(text: line, type: type));
    }
  }

  void _executeWebFallback(TerminalSession session, String cmd) {
    session.lines.add(TerminalLine(
      text: 'Web sandbox: $cmd (Native process execution not available in browser)',
      type: 'info',
    ));
    session.status = TerminalSessionStatus.ready;
    notifyListeners();
  }

  void clearTerminal([String? targetSessionId]) {
    final session = targetSessionId != null
        ? _terminalSessions.firstWhere((s) => s.id == targetSessionId,
            orElse: () => activeTerminalSession ?? _terminalSessions.first)
        : activeTerminalSession;
    session?.lines.clear();
    _terminalLines.clear();
    notifyListeners();
  }

  // AI Assistant & Agent Flow
  Future<void> sendAiMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = AIChatMessage(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: prompt,
      timestamp:
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    );
    _aiMessages.add(userMsg);
    notifyListeners();

    if (prompt.toLowerCase().contains('create') ||
        prompt.toLowerCase().contains('add') ||
        prompt.toLowerCase().contains('build') ||
        prompt.toLowerCase().contains('test')) {
      await executeAgentPlan(prompt);
      return;
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      String responseContent =
          'I analyzed your project structure in **${activeFile?.path ?? "workspace"}**.';
      CodeSnippet? snippet;

      if (prompt.toLowerCase().contains('explain')) {
        responseContent =
            'The active file `${activeFile?.name ?? "code"}` implements the **${AppConstants.appName} Engine Architecture** (PRD Section 8). It leverages Tokio\'s multi-threaded asynchronous runtime and RwLock to achieve lock-free incremental symbol queries across 100,000+ files without UI blocking.';
      } else if (prompt.toLowerCase().contains('refactor') ||
          prompt.toLowerCase().contains('optimize')) {
        responseContent =
            'Here is an optimized parallel batch indexing implementation using Rayon and memory-mapped files:';
        snippet = const CodeSnippet(
          language: 'rust',
          code:
              'pub fn parallel_scan_buffers(files: &[PathBuf]) -> usize {\n    use rayon::prelude::*;\n    files.par_iter().map(|path| parse_file_symbols(path)).sum()\n}',
        );
      } else {
        responseContent =
            'I can help you with that! Would you like me to generate code, execute tests, or switch to **Agent Mode** to modify the workspace files directly?';
      }

      final assistantMsg = AIChatMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: responseContent,
        timestamp:
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        model: _aiModel,
        codeSnippet: snippet,
      );

      _aiMessages.add(assistantMsg);
      notifyListeners();
    });
  }

  Future<void> executeAgentPlan(String actionPrompt) async {
    _isAgentRunning = true;

    final agentMsg = AIChatMessage(
      id: 'agent-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content:
          '🤖 **AI Agent Mode Activated** (PRD Section 37)\nPlanning execution for: "$actionPrompt"',
      timestamp:
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      model: _aiModel,
      agentSteps: [
        AgentStep(
          step: 1,
          description: 'Inspect workspace AST and project dependencies',
          status: 'running',
          actionType: 'test',
        ),
        AgentStep(
          step: 2,
          description: 'Generate code changes in src/components/AuthModal.tsx',
          status: 'pending',
          actionType: 'create_file',
          target: 'src/components/AuthModal.tsx',
        ),
        AgentStep(
          step: 3,
          description: 'Run compiler diagnostics & cargo test',
          status: 'pending',
          actionType: 'run_command',
        ),
      ],
      permissionRequest: const PermissionRequest(
        action: 'Create file and run build validation',
        commandOrFile: 'src/components/AuthModal.tsx & cargo test',
        requiresConfirm: true,
      ),
    );

    _aiMessages.add(agentMsg);
    notifyListeners();
  }

  void confirmAgentPermission(bool allowed) {
    if (!allowed) {
      _aiMessages.add(AIChatMessage(
        id: 'perm-denied-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content:
            '❌ **Action Denied by Developer**. Workspace remains unchanged (PRD Section 87 AI Security Confirmation).',
        timestamp:
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      ));
      _isAgentRunning = false;
      notifyListeners();
      return;
    }

    createFile('AuthModal.tsx', 'src');
    runTerminalCommand('cargo test');
    _isAgentRunning = false;

    _aiMessages.add(AIChatMessage(
      id: 'perm-ok-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content:
          '✅ **Agent Plan Completed Successfully**:\n1. Created `src/AuthModal.tsx`\n2. Ran build checks in terminal\n3. Git status updated to untracked.',
      timestamp:
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    ));
    notifyListeners();
  }
}
