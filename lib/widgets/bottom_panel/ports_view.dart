import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';

class PortsView extends StatelessWidget {
  const PortsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    return Container(
      color: theme.editorBg,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forwarded Ports & Live Application Preview (PRD §67)',
            style: TextStyle(fontSize: 11, color: theme.textDim),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: wp.ports.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final port = wp.ports[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      Text(
                        '${port.port}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textMain, fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 8),
                      Text(port.name, style: TextStyle(fontSize: 11, color: theme.textMuted)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(port.status, style: const TextStyle(fontSize: 9, color: Color(0xFF10B981))),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.visibility, size: 11),
                        label: const Text('Open Preview', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => wp.setPreviewUrl(port.address),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 12),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        tooltip: 'Copy Address',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: port.address));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied ${port.address} to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
