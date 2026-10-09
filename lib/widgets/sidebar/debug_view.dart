import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';

class DebugView extends StatefulWidget {
  const DebugView({super.key});

  @override
  State<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<DebugView> {
  String _selectedConfig = 'Launch Rust Core (Target: Debug)';
  bool _isDebugging = false;

  final List<Map<String, dynamic>> _breakpoints = [
    {'id': 'bp-1', 'file': 'src/main.rs', 'line': 29, 'active': true},
    {'id': 'bp-2', 'file': 'src/engine/indexer.rs', 'line': 34, 'active': true},
    {'id': 'bp-3', 'file': 'src/ai/agent.py', 'line': 18, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    return Column(
      children: [
        // Header
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.borderSubtle)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            'Run and Debug',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Config selector
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedConfig,
                    isExpanded: true,
                    dropdownColor: theme.bgPanel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedConfig = val);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Launch Rust Core (Target: Debug)',
                        child: Text('Launch Rust Core (DAP: LLDB)'),
                      ),
                      DropdownMenuItem(
                        value: 'Start Vite Dev Server',
                        child: Text('Start Vite Dev Server (Chrome)'),
                      ),
                      DropdownMenuItem(
                        value: 'Python AI Agent',
                        child: Text('Python AI Agent (debugpy)'),
                      ),
                      DropdownMenuItem(
                        value: 'Cargo Test Suite',
                        child: Text('Cargo Test Suite'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Debug start/stop button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(_isDebugging ? Icons.stop : Icons.play_arrow, size: 14),
                      label: Text(_isDebugging ? 'Stop' : 'Start Debugging'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDebugging
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () {
                        setState(() => _isDebugging = !_isDebugging);
                        if (_isDebugging) {
                          wp.setBottomPanelTab(BottomPanelTab.debugConsole);
                          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
                          wp.runTerminalCommand('lldb --attach-name ${wp.workspaceName.replaceAll(' ', '-').toLowerCase()}');
                        } else {
                          wp.runTerminalCommand('Debug session terminated.');
                        }
                      },
                    ),
                  ),
                  if (_isDebugging) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 14),
                      tooltip: 'Restart Debugger',
                      onPressed: () => wp.runTerminalCommand('Debugger restarted'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              // Variables
              Text(
                'VARIABLES (LOCAL)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textDim),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('config: WorkspaceConfig',
                        style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontFamily: 'monospace')),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text('max_file_cache_mb: 512',
                          style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontFamily: 'monospace')),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text('enable_lsp: true',
                          style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontFamily: 'monospace')),
                    ),
                    const SizedBox(height: 4),
                    const Text('indexer: Arc<RwLock<ProjectIndexer>>',
                        style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Watch expressions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('WATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textDim)),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Watch expression added.')),
                      );
                    },
                    child: Icon(Icons.add, size: 13, color: theme.textDim),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('indexer.indexed_files: 142',
                  style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontFamily: 'monospace')),
              const SizedBox(height: 12),

              // Breakpoints
              Text(
                'BREAKPOINTS (${_breakpoints.where((b) => b['active'] as bool).length})',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textDim),
              ),
              const SizedBox(height: 4),
              ..._breakpoints.map((bp) {
                final isActive = bp['active'] as bool;
                return InkWell(
                  onTap: () {
                    setState(() => bp['active'] = !isActive);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.circle : Icons.circle_outlined,
                          size: 11,
                          color: isActive ? const Color(0xFFF43F5E) : theme.textDim,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${bp['file']}:${bp['line']}',
                            style: TextStyle(fontSize: 11, color: theme.textMain, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
