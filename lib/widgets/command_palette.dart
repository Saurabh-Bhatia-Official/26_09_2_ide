import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/file_item.dart';
import '../../models/ide_types.dart';
import '../../models/platform_mode.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _controller = TextEditingController(text: '');
  int _selectedIndex = 0;
  String _filterMode = 'all'; // 'all', 'files', 'commands'
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<FileItem> _flatten(List<FileItem> items) {
    final List<FileItem> res = [];
    for (final item in items) {
      if (!item.isFolder) {
        res.add(item);
      } else if (item.children != null) {
        res.addAll(_flatten(item.children!));
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    if (!wp.isCommandPaletteOpen) return const SizedBox.shrink();

    final theme = wp.theme;
    final isMac = wp.platformMode == PlatformMode.mac;
    final query = _controller.text;
    final isCommandMode = query.startsWith('>');
    final cleanQuery = isCommandMode ? query.substring(1).trim().toLowerCase() : query.trim().toLowerCase();

    final List<Map<String, dynamic>> commands = [
      {
        'id': 'cmd-open-folder',
        'title': 'File: Open Folder from Disk...',
        'category': 'File',
        'shortcut': isMac ? '⌘O' : 'Ctrl+O',
        'icon': Icons.folder_open,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.openFolder(),
      },
      {
        'id': 'cmd-open-file',
        'title': 'File: Open Single File...',
        'category': 'File',
        'shortcut': '',
        'icon': Icons.file_upload_outlined,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.openSingleFile(),
      },
      {
        'id': 'cmd-new-file',
        'title': 'File: New File...',
        'category': 'File',
        'shortcut': 'Ctrl+N',
        'icon': Icons.note_add_outlined,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.createFile('untitled.rs'),
      },
      {
        'id': 'cmd-word-wrap',
        'title': 'Preferences: Toggle Work Wrap (Word Wrap)',
        'category': 'Editor',
        'shortcut': '',
        'icon': Icons.wrap_text,
        'iconColor': const Color(0xFFF59E0B),
        'run': () => wp.toggleWordWrap(),
      },
      {
        'id': 'cmd-settings',
        'title': 'Preferences: Open User Settings',
        'category': 'Preferences',
        'shortcut': 'Ctrl+,',
        'icon': Icons.settings_outlined,
        'iconColor': theme.accent,
        'run': () => wp.setActivityTab(ActivityTab.settings),
      },
      {
        'id': 'cmd-build',
        'title': 'Tasks: Run Build Task (cargo build)',
        'category': 'Build',
        'shortcut': isMac ? '⌘Shift+B' : 'Ctrl+Shift+B',
        'icon': Icons.play_arrow,
        'iconColor': const Color(0xFF10B981),
        'run': () => wp.runTerminalCommand('cargo build'),
      },
      {
        'id': 'cmd-run',
        'title': 'Tasks: Run Project (cargo run)',
        'category': 'Run',
        'shortcut': 'F5',
        'icon': Icons.rocket_launch,
        'iconColor': const Color(0xFF10B981),
        'run': () => wp.runTerminalCommand('cargo run'),
      },
      {
        'id': 'cmd-test',
        'title': 'Tasks: Run All Tests (cargo test)',
        'category': 'Test',
        'shortcut': 'Ctrl+Shift+T',
        'icon': Icons.science_outlined,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.runTerminalCommand('cargo test'),
      },
      {
        'id': 'cmd-ai',
        'title': 'AI: Toggle Mingo Copilot Assistant',
        'category': 'AI',
        'shortcut': 'Ctrl+Shift+A',
        'icon': Icons.auto_awesome,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.toggleAiPanel(),
      },
      {
        'id': 'cmd-term',
        'title': 'View: Toggle Integrated Terminal',
        'category': 'View',
        'shortcut': 'Ctrl+`',
        'icon': Icons.terminal,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.toggleBottomPanel(),
      },
      {
        'id': 'cmd-sidebar',
        'title': 'View: Toggle Primary Sidebar',
        'category': 'View',
        'shortcut': 'Ctrl+B',
        'icon': Icons.vertical_split,
        'iconColor': const Color(0xFF38BDF8),
        'run': () => wp.toggleSidebar(),
      },
      {
        'id': 'cmd-git-commit',
        'title': 'Git: Commit Staged Changes',
        'category': 'Git',
        'shortcut': 'Ctrl+Enter',
        'icon': Icons.fork_right,
        'iconColor': const Color(0xFFF59E0B),
        'run': () => wp.setActivityTab(ActivityTab.git),
      },
      {
        'id': 'cmd-format',
        'title': 'Format Document (Prettier / rustfmt)',
        'category': 'Editor',
        'shortcut': 'Shift+Alt+F',
        'icon': Icons.code,
        'iconColor': const Color(0xFFA855F7),
        'run': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document formatted successfully.')),
          );
        },
      },
    ];

    final allFiles = _flatten(wp.files);

    // Build unified item list
    final List<Map<String, dynamic>> unifiedItems = [];

    final bool showCommands = _filterMode == 'all' || _filterMode == 'commands' || isCommandMode;
    final bool showFiles = (_filterMode == 'all' || _filterMode == 'files') && !isCommandMode;

    if (showFiles) {
      for (final f in allFiles) {
        if (cleanQuery.isEmpty ||
            f.name.toLowerCase().contains(cleanQuery) ||
            f.path.toLowerCase().contains(cleanQuery)) {
          unifiedItems.add({
            'type': 'file',
            'title': f.name,
            'subtitle': f.path,
            'shortcut': '',
            'icon': Icons.description_outlined,
            'iconColor': const Color(0xFF38BDF8),
            'action': () => wp.openFile(f),
          });
        }
      }
    }

    if (showCommands) {
      for (final c in commands) {
        final title = (c['title'] as String).toLowerCase();
        final cat = (c['category'] as String).toLowerCase();
        if (cleanQuery.isEmpty || title.contains(cleanQuery) || cat.contains(cleanQuery)) {
          unifiedItems.add({
            'type': 'command',
            'title': c['title'] as String,
            'subtitle': c['category'] as String,
            'shortcut': c['shortcut'] as String,
            'icon': c['icon'] as IconData,
            'iconColor': c['iconColor'] ?? theme.textMuted,
            'action': c['run'] as VoidCallback,
          });
        }
      }
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            wp.setCommandPaletteOpen(false);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _selectedIndex = (_selectedIndex + 1).clamp(0, unifiedItems.isEmpty ? 0 : unifiedItems.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _selectedIndex = (_selectedIndex - 1).clamp(0, unifiedItems.isEmpty ? 0 : unifiedItems.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (unifiedItems.isNotEmpty && _selectedIndex < unifiedItems.length) {
              final selected = unifiedItems[_selectedIndex];
              (selected['action'] as VoidCallback)();
              wp.setCommandPaletteOpen(false);
            }
          }
        }
      },
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () => wp.setCommandPaletteOpen(false),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          // Dialog Box
          Align(
            alignment: const Alignment(0, -0.6),
            child: Container(
              width: 580,
              constraints: const BoxConstraints(maxHeight: 420),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.bgPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.border),
                boxShadow: const [
                  BoxShadow(color: Colors.black87, blurRadius: 25, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: theme.borderSubtle)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: TextStyle(fontSize: 13, color: theme.textMain),
                            decoration: InputDecoration(
                              hintText: "Search files & commands (prefix '>' for commands)...",
                              hintStyle: TextStyle(fontSize: 12, color: theme.textDim),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) {
                              setState(() => _selectedIndex = 0);
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('ESC', style: TextStyle(fontSize: 9, color: Colors.white60)),
                        ),
                      ],
                    ),
                  ),

                  // Filter Mode Selector Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      border: Border(bottom: BorderSide(color: theme.borderSubtle)),
                    ),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All (${unifiedItems.length})', theme),
                        const SizedBox(width: 6),
                        _buildFilterChip('files', 'Files', theme),
                        const SizedBox(width: 6),
                        _buildFilterChip('commands', 'Commands', theme),
                        const Spacer(),
                        Text(
                          isCommandMode ? 'Command Mode (>)' : 'Files & Commands',
                          style: TextStyle(fontSize: 10, color: theme.textDim),
                        ),
                      ],
                    ),
                  ),

                  // Results list
                  Flexible(
                    child: unifiedItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No matching files or commands found',
                              style: TextStyle(color: theme.textDim, fontSize: 12),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: unifiedItems.length,
                            itemBuilder: (context, index) {
                              final item = unifiedItems[index];
                              final isSelected = index == _selectedIndex;
                              final isFile = item['type'] == 'file';

                              return InkWell(
                                onTap: () {
                                  (item['action'] as VoidCallback)();
                                  wp.setCommandPaletteOpen(false);
                                },
                                child: Container(
                                  color: isSelected ? theme.accent.withValues(alpha: 0.2) : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        size: 14,
                                        color: item['iconColor'] as Color,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isFile
                                              ? const Color(0xFF38BDF8).withValues(alpha: 0.12)
                                              : const Color(0xFFA855F7).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Text(
                                          isFile ? 'FILE' : 'CMD',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: isFile ? const Color(0xFF38BDF8) : const Color(0xFFA855F7),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['title'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected ? Colors.white : theme.textMain,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if ((item['subtitle'] as String).isNotEmpty && isFile) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          item['subtitle'] as String,
                                          style: TextStyle(fontSize: 10, color: theme.textDim),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if ((item['shortcut'] as String).isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          item['shortcut'] as String,
                                          style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: theme.textDim),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String mode, String label, dynamic theme) {
    final isSelected = _filterMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _filterMode = mode;
          _selectedIndex = 0;
        });
      },
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: isSelected ? theme.accent : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : theme.textDim,
          ),
        ),
      ),
    );
  }
}
