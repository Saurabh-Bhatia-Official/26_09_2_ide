import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/platform_mode.dart';
import '../../constants/app_constants.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  void _showNewFileDialog(BuildContext context, WorkspaceProvider wp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: wp.theme.bgSurface,
        title: Text('New File', style: TextStyle(color: wp.theme.textMain, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: wp.theme.textMain, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. index.ts, main.py',
            hintStyle: TextStyle(color: wp.theme.textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.accent)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              wp.createFile(val.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: wp.theme.textDim)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: wp.theme.accent),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                wp.createFile(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final isMac = wp.platformMode == PlatformMode.mac;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brand Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 36, spreadRadius: 4),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  AppConstants.appIconAsset,
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                      ),
                      boxShadow: [
                        BoxShadow(color: theme.accentGlow, blurRadius: 30),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      AppConstants.appLogoLetter,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'One development environment. Every device. One connected workspace.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: theme.textMuted),
              ),
              const SizedBox(height: 24),

              // Action buttons
              // Open folder
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: wp.openFolder,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.folder_open, size: 16, color: Color(0xFF38BDF8)),
                        SizedBox(width: 8),
                        Text('Open Folder...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        isMac ? '⌘O' : 'Ctrl+O',
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // New file
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textMain,
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  side: BorderSide(color: theme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showNewFileDialog(context, wp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.note_add_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('New File...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        isMac ? '⌘N' : 'Ctrl+N',
                        style: TextStyle(fontSize: 10, color: theme.textDim),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Open file
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textMain,
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  side: BorderSide(color: theme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: wp.openSingleFile,
                child: const Row(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Open File...', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Keyboard shortcuts
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildShortcutChip('${isMac ? "⌘" : "Ctrl"}+P Quick Open', theme),
                  _buildShortcutChip('${isMac ? "⌘" : "Ctrl"}+` Terminal', theme),
                  _buildShortcutChip('${isMac ? "⌘" : "Ctrl"}+Shift+A AI Copilot', theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutChip(String label, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: theme.textDim),
      ),
    );
  }
}
