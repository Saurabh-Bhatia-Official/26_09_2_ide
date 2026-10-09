import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';

class DebugConsoleView extends StatefulWidget {
  const DebugConsoleView({super.key});

  @override
  State<DebugConsoleView> createState() => _DebugConsoleViewState();
}

class _DebugConsoleViewState extends State<DebugConsoleView> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _logs = [
    'Debugger initialized - Ready for process attachment',
    'Type expressions or commands below to inspect state at runtime',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _eval() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _logs.add('> $text');
        _logs.add('Evaluated ($text) => Ok("Ready")');
        _inputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    return Container(
      color: theme.editorBg,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return SelectableText(
                  log,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: log.startsWith('>') ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1),
                    height: 1.45,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
            ),
            child: Row(
              children: [
                const Text(
                  '> ',
                  style: TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontSize: 13),
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Evaluate expression in debug session (e.g. config, indexer.len())...',
                      hintStyle: TextStyle(color: theme.textDim, fontSize: 11),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _eval(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
