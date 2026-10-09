import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/terminal_session.dart';
import '../../providers/workspace_provider.dart';

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int _historyIndex = -1;
  String _savedCurrentInput = '';
  int _lastLinesCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitCommand(WorkspaceProvider wp) {
    final text = _inputController.text;
    wp.runTerminalCommand(text);
    _inputController.clear();
    _historyIndex = -1;
    _savedCurrentInput = '';
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, WorkspaceProvider wp) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final session = wp.activeTerminalSession;
    if (session == null) return KeyEventResult.ignored;

    // Up Arrow: History backward
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (session.history.isNotEmpty) {
        if (_historyIndex == -1) {
          _savedCurrentInput = _inputController.text;
          _historyIndex = session.history.length - 1;
        } else if (_historyIndex > 0) {
          _historyIndex--;
        }
        final cmd = session.history[_historyIndex];
        _inputController.text = cmd;
        _inputController.selection = TextSelection.collapsed(offset: cmd.length);
        return KeyEventResult.handled;
      }
    }

    // Down Arrow: History forward
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex != -1) {
        if (_historyIndex < session.history.length - 1) {
          _historyIndex++;
          final cmd = session.history[_historyIndex];
          _inputController.text = cmd;
          _inputController.selection = TextSelection.collapsed(offset: cmd.length);
        } else {
          _historyIndex = -1;
          _inputController.text = _savedCurrentInput;
          _inputController.selection = TextSelection.collapsed(offset: _savedCurrentInput.length);
        }
        return KeyEventResult.handled;
      }
    }

    // Ctrl+C: Cancel current command line
    if (event.logicalKey == LogicalKeyboardKey.keyC &&
        HardwareKeyboard.instance.isControlPressed) {
      wp.cancelCurrentCommand();
      _inputController.clear();
      _historyIndex = -1;
      _savedCurrentInput = '';
      _scrollToBottom();
      return KeyEventResult.handled;
    }

    // Ctrl+L: Clear screen
    if (event.logicalKey == LogicalKeyboardKey.keyL &&
        HardwareKeyboard.instance.isControlPressed) {
      wp.clearTerminal(session.id);
      _inputController.clear();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final session = wp.activeTerminalSession ??
        (wp.terminalSessions.isNotEmpty ? wp.terminalSessions.first : null);
    final availableShells = wp.availableShells;

    if (session != null && session.lines.length != _lastLinesCount) {
      _lastLinesCount = session.lines.length;
      _scrollToBottom();
    }

    return Container(
      color: theme.editorBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          // Sub-header with multi-terminal tabs and controls
          Container(
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                // Multi-session tabs
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...wp.terminalSessions.map((s) {
                          final isActive = s.id == session?.id;
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            height: 24,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.accent.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: isActive
                                    ? theme.accent.withValues(alpha: 0.5)
                                    : theme.borderSubtle,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    wp.switchTerminalSession(s.id);
                                    _focusNode.requestFocus();
                                    _scrollToBottom();
                                  },
                                  borderRadius: BorderRadius.circular(3),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      s.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            isActive ? FontWeight.w600 : FontWeight.normal,
                                        color: isActive
                                            ? const Color(0xFF38BDF8)
                                            : theme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                if (wp.terminalSessions.length > 1)
                                  InkWell(
                                    onTap: () => wp.closeTerminalSession(s.id),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 6, left: 2),
                                      child: Icon(
                                        Icons.close,
                                        size: 11,
                                        color: theme.textDim,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // + New Terminal button
                        InkWell(
                          onTap: () {
                            wp.createTerminalSession();
                            _scrollToBottom();
                            _focusNode.requestFocus();
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: theme.borderSubtle),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, size: 12, color: Color(0xFF38BDF8)),
                                SizedBox(width: 4),
                                Text(
                                  'New Terminal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Shell selector dropdown (only showing detected available shells for this OS)
                if (session != null && availableShells.isNotEmpty)
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.borderSubtle),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ShellInfo>(
                        value: availableShells.contains(session.shell)
                            ? session.shell
                            : (availableShells.isNotEmpty ? availableShells.first : null),
                        dropdownColor: theme.bgPanel,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                        icon: const Icon(Icons.arrow_drop_down, size: 14),
                        onChanged: (val) {
                          if (val != null) {
                            wp.changeTerminalShell(session.id, val);
                            _focusNode.requestFocus();
                          }
                        },
                        items: availableShells.map((shell) {
                          return DropdownMenuItem<ShellInfo>(
                            value: shell,
                            child: Text(
                              shell.name + (shell.isDefault ? ' (Default)' : ''),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                // Ready status indicator
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: session?.status == TerminalSessionStatus.ready
                          ? const Color(0xFF10B981)
                          : const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session?.status == TerminalSessionStatus.ready ? 'Ready' : 'Running',
                      style: TextStyle(
                        fontSize: 10,
                        color: session?.status == TerminalSessionStatus.ready
                            ? const Color(0xFF10B981)
                            : const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 6),

                // Clear terminal button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  tooltip: 'Clear Terminal Buffer (Ctrl+L)',
                  onPressed: () {
                    wp.clearTerminal(session?.id);
                    _focusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),

          // Continuous Terminal Screen: output lines with active cursor embedded directly inside
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _focusNode.requestFocus(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                children: [
                  // Previous output lines
                  if (session != null)
                    ...session.lines.map((line) {
                      Color color = const Color(0xFFCBD5E1);
                      if (line.type == 'error') color = const Color(0xFFF43F5E);
                      if (line.type == 'success') color = const Color(0xFF10B981);
                      if (line.type == 'cmd') color = const Color(0xFF38BDF8);
                      if (line.type == 'info') color = const Color(0xFF94A3B8);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: SelectableText(
                          line.text,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: color,
                            height: 1.4,
                          ),
                        ),
                      );
                    }),

                  // Active terminal prompt and cursor line directly inside the terminal
                  if (session != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (session.status == TerminalSessionStatus.running) ...[
                            const Icon(
                              Icons.sync_rounded,
                              size: 13,
                              color: Color(0xFF38BDF8),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Running... ',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF38BDF8),
                                height: 1.4,
                              ),
                            ),
                          ] else ...[
                            Text(
                              session.prompt,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                                height: 1.4,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Focus(
                              onKeyEvent: (node, event) =>
                                  _handleKeyEvent(node, event, wp),
                              child: TextField(
                                controller: _inputController,
                                focusNode: _focusNode,
                                autofocus: true,
                                readOnly: session.status == TerminalSessionStatus.running,
                                cursorColor: session.status == TerminalSessionStatus.running
                                    ? Colors.transparent
                                    : const Color(0xFF38BDF8),
                                cursorWidth: 7, // Authentic terminal block cursor
                                cursorHeight: 14,
                                cursorRadius: Radius.zero,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: session.status == TerminalSessionStatus.running
                                      ? const Color(0xFF38BDF8).withValues(alpha: 0.8)
                                      : Colors.white,
                                  height: 1.4,
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: session.status == TerminalSessionStatus.running
                                      ? '(wait till command completes or Ctrl+C to abort)'
                                      : null,
                                  hintStyle: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                  ),
                                ),
                                onSubmitted: (_) => _submitCommand(wp),
                              ),
                            ),
                          ),
                        ],
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
}
