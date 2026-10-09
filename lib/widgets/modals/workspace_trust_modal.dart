import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../constants/app_constants.dart';

class WorkspaceTrustModal extends StatefulWidget {
  const WorkspaceTrustModal({super.key});

  @override
  State<WorkspaceTrustModal> createState() => _WorkspaceTrustModalState();
}

class _WorkspaceTrustModalState extends State<WorkspaceTrustModal> {
  bool _dismissed = true; // By default workspace is trusted

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    if (_dismissed) return const SizedBox.shrink();

    final theme = wp.theme;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _dismissed = true),
          child: Container(color: Colors.black.withValues(alpha: 0.65)),
        ),
        Center(
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.bgPanel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.shield_outlined, size: 20, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Workspace Trust Configuration (PRD §86)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.textMain)),
                        Text(wp.workspaceName, style: TextStyle(fontSize: 11, color: theme.textDim)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Trusting this workspace grants ${AppConstants.appName} and installed extensions permission to execute background tasks, compile native binaries, and run terminal commands.',
                  style: TextStyle(fontSize: 12, color: theme.textMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('In Restricted Mode, potentially disabled:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textMain)),
                      const SizedBox(height: 4),
                      Text('• Automatic tasks & background compilation',
                          style: TextStyle(fontSize: 11, color: theme.textDim)),
                      Text('• Unsandboxed extensions & DAP debugging',
                          style: TextStyle(fontSize: 11, color: theme.textDim)),
                      Text('• Autonomous AI agent command execution',
                          style: TextStyle(fontSize: 11, color: theme.textDim)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.textMuted,
                        side: BorderSide(color: theme.border),
                      ),
                      onPressed: () {
                        wp.setWorkspaceTrusted(false);
                        setState(() => _dismissed = true);
                      },
                      child: const Text('Restricted Mode'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Trust Workspace'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        wp.setWorkspaceTrusted(true);
                        setState(() => _dismissed = true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
