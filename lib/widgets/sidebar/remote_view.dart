import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/ide_types.dart';

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  final List<RemoteTarget> _remotes = [
    RemoteTarget(
      id: 'rem-1',
      name: '${AppConstants.appShortName} Cloud Dev VM (us-east)',
      type: 'cloud',
      ip: '10.240.12.8',
      status: 'connected',
      specs: '8 vCPU, 32GB RAM, 100GB NVMe',
      latency: '18ms',
    ),
    RemoteTarget(
      id: 'rem-2',
      name: 'Ubuntu Staging Cluster (SSH)',
      type: 'ssh',
      ip: '192.168.1.105:22',
      status: 'disconnected',
      specs: 'Linux 6.8.0-generic',
      latency: '4ms',
    ),
    RemoteTarget(
      id: 'rem-3',
      name: 'App Sandbox (Docker Container)',
      type: 'container',
      ip: 'local-docker://mingo-runtime',
      status: 'connected',
      specs: 'alpine-node:20',
      latency: '1ms',
    ),
  ];

  void _showAddHostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.read<WorkspaceProvider>().theme.bgSurface,
        title: const Text('Add SSH Host', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'user@hostname:port',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _remotes.add(RemoteTarget(
                    id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
                    name: controller.text.trim(),
                    type: 'ssh',
                    ip: controller.text.trim(),
                    status: 'disconnected',
                    specs: 'Remote SSH Host',
                    latency: '35ms',
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Remote & Cloud Workspaces',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Add SSH Host',
                onPressed: () => _showAddHostDialog(context),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Connect your editor to high-performance remote Linux servers, Docker containers, or ${AppConstants.appShortName} Cloud instances.',
            style: TextStyle(fontSize: 11, color: theme.textMuted, height: 1.3),
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: _remotes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final target = _remotes[index];
              final isConn = target.status == 'connected';

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          target.type == 'cloud'
                              ? Icons.cloud_outlined
                              : (target.type == 'ssh' ? Icons.dns_outlined : Icons.inbox_outlined),
                          size: 14,
                          color: target.type == 'cloud'
                              ? const Color(0xFF38BDF8)
                              : (target.type == 'ssh' ? const Color(0xFFA855F7) : const Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            target.name,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isConn
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            target.status,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isConn ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(target.specs ?? '', style: TextStyle(fontSize: 10, color: theme.textDim)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi, size: 10, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  target.latency ?? '',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.terminal, size: 10),
                          label: Text(isConn ? 'Disconnect' : 'Connect', style: const TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.06),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            setState(() {
                              target.status = isConn ? 'disconnected' : 'connected';
                            });
                            wp.setBottomPanelTab(BottomPanelTab.terminal);
                            if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
                            wp.runTerminalCommand('ssh root@${target.name} -p 22');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
