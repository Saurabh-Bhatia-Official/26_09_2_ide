import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';

class OutputView extends StatefulWidget {
  const OutputView({super.key});

  @override
  State<OutputView> createState() => _OutputViewState();
}

class _OutputViewState extends State<OutputView> {
  String _channel = 'Mingo Language Engine';

  final Map<String, List<String>> _logs = {
    'Mingo Language Engine': [
      '[INFO] Language server initialized and indexing workspace symbols',
      '[INFO] AST syntax parser ready for real-time diagnostics and completion',
      '[INFO] Code intelligence watcher operational',
    ],
    'Mingo Engine Daemon': [
      '[DAEMON] Background worker process pool active',
      '[DAEMON] FileSystem watcher initialized with immediate change notifications',
      '[DAEMON] Local runtime daemon ready',
    ],
    'Application Build Server': [
      '[BUILD] Development build server initialized',
      '[BUILD] Live reload ready on file change',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final channelLogs = _logs[_channel] ?? [];

    return Container(
      color: theme.editorBg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Channel: ', style: TextStyle(fontSize: 11, color: theme.textDim)),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.borderSubtle),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _channel,
                    dropdownColor: theme.bgPanel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    onChanged: (val) {
                      if (val != null) setState(() => _channel = val);
                    },
                    items: _logs.keys
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: channelLogs.length,
              itemBuilder: (context, index) {
                return SelectableText(
                  channelLogs[index],
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF94A3B8), height: 1.45),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
