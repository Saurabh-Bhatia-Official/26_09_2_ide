import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/workspace_provider.dart';
import '../models/platform_mode.dart';
import '../models/theme_definition.dart';
import '../constants/app_constants.dart';

class TitleBar extends StatefulWidget {
  final bool isMobile;
  const TitleBar({super.key, required this.isMobile});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  Future<void> _safeMinimize() async {
    if (kIsWeb) return;
    try {
      await windowManager.minimize();
    } catch (_) {}
  }

  Future<void> _safeToggleMaximize() async {
    if (kIsWeb) return;
    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  Future<void> _safeClose() async {
    if (kIsWeb) return;
    try {
      await windowManager.close();
    } catch (_) {}
  }

  Widget _buildWindowControlButton({
    required IconData icon,
    required double iconSize,
    required String tooltip,
    required VoidCallback onTap,
    required ThemeDefinition theme,
    bool isClose = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      hoverColor: isClose ? const Color(0xFFE81123) : theme.accent.withValues(alpha: 0.15),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        child: Tooltip(
          message: tooltip,
          child: Icon(icon, size: iconSize, color: theme.textDim),
        ),
      ),
    );
  }

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
            hintText: 'e.g. main.rs, App.tsx, script.py',
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

  void _showNewFolderDialog(BuildContext context, WorkspaceProvider wp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: wp.theme.bgSurface,
        title: Text('New Folder', style: TextStyle(color: wp.theme.textMain, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: wp.theme.textMain, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Folder name...',
            hintStyle: TextStyle(color: wp.theme.textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.accent)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              wp.createFolder(val.trim());
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
                wp.createFolder(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      String title, List<PopupMenuEntry<String>> items, WorkspaceProvider wp) {
    return PopupMenuButton<String>(
      tooltip: '',
      color: wp.theme.bgPanel,
      offset: const Offset(0, 30),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: wp.theme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: wp.theme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      itemBuilder: (context) => items,
      onSelected: (val) {
        if (val == 'open_folder') wp.openFolder();
        if (val == 'open_file') wp.openSingleFile();
        if (val == 'new_file') _showNewFileDialog(context, wp);
        if (val == 'new_folder') _showNewFolderDialog(context, wp);
        if (val == 'save') wp.saveActiveFile();
        if (val == 'palette') wp.setCommandPaletteOpen(true);
        if (val == 'toggle_sidebar') wp.toggleSidebar();
        if (val == 'toggle_panel') wp.toggleBottomPanel();
        if (val == 'toggle_ai') wp.toggleAiPanel();
        if (val == 'debug') {
          wp.runTerminalCommand('cargo run');
          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
        }
        if (val == 'run_vite') {
          wp.runTerminalCommand('npm run dev');
          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
        }
        if (val == 'new_term') {
          wp.runTerminalCommand('echo "--- New Terminal Session Initialized ---"');
          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
        }
        if (val == 'build_task') {
          wp.runTerminalCommand('cargo build');
          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
        }
        if (val == 'about') _showAboutMingoDialog(context, wp.theme);
        if (val == 'shortcuts') wp.setCommandPaletteOpen(true);
      },
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, String shortcut,
      IconData icon, WorkspaceProvider wp, [Color? iconColor]) {
    return PopupMenuItem<String>(
      value: value,
      height: 32,
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? wp.theme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: iconColor ?? wp.theme.textMain,
                fontWeight: iconColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (shortcut.isNotEmpty)
            Text(
              shortcut,
              style: TextStyle(fontSize: 10, color: wp.theme.textDim),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMac = wp.platformMode == PlatformMode.mac;
        final isWide = constraints.maxWidth >= 1050 && !widget.isMobile;
        final isMedium = constraints.maxWidth >= 640 && !widget.isMobile;
        final needsScrollFallback = constraints.maxWidth < 360;

        final titleRow = Row(
          children: [
          // Mac Traffic Lights
          if (isMac && !widget.isMobile) ...[
            InkWell(
              onTap: _safeClose,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: _safeMinimize,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: _safeToggleMaximize,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Mobile Drawer Hamburger Button
          if (widget.isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, size: 18),
              color: const Color(0xFF38BDF8),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => wp.setMobileDrawerOpen(true),
              tooltip: 'Open Drawer',
            ),
            const SizedBox(width: 4),
          ],

          // Brand Logo
          InkWell(
            onTap: () => _showAboutMingoDialog(context, theme),
            borderRadius: BorderRadius.circular(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: theme.accentGlow, blurRadius: 8),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppConstants.appIconAsset,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        AppConstants.appLogoLetter,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: theme.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menus on desktop
          if (!widget.isMobile && isWide) ...[
            const SizedBox(width: 12),
            _buildMenuButton(
              'File',
              [
                _menuItem('open_folder', 'Open Folder...', isMac ? '⌘O' : 'Ctrl+O', Icons.folder_open, wp, const Color(0xFF38BDF8)),
                _menuItem('open_file', 'Open File...', '', Icons.file_upload_outlined, wp),
                const PopupMenuDivider(height: 8),
                _menuItem('new_file', 'New File...', isMac ? '⌘N' : 'Ctrl+N', Icons.note_add_outlined, wp),
                _menuItem('new_folder', 'New Folder...', '', Icons.create_new_folder_outlined, wp),
                const PopupMenuDivider(height: 8),
                _menuItem('save', 'Save', isMac ? '⌘S' : 'Ctrl+S', Icons.save_outlined, wp),
              ],
              wp,
            ),
            _buildMenuButton(
              'Edit',
              [
                _menuItem('undo', 'Undo', isMac ? '⌘Z' : 'Ctrl+Z', Icons.undo, wp),
                _menuItem('redo', 'Redo', isMac ? '⌘Y' : 'Ctrl+Y', Icons.redo, wp),
                const PopupMenuDivider(height: 8),
                _menuItem('cut', 'Cut', isMac ? '⌘X' : 'Ctrl+X', Icons.content_cut, wp),
                _menuItem('copy', 'Copy', isMac ? '⌘C' : 'Ctrl+C', Icons.content_copy, wp),
                _menuItem('paste', 'Paste', isMac ? '⌘V' : 'Ctrl+V', Icons.content_paste, wp),
              ],
              wp,
            ),
            _buildMenuButton(
              'View',
              [
                _menuItem('palette', 'Command Palette...', isMac ? '⌘P' : 'Ctrl+P', Icons.search, wp),
                const PopupMenuDivider(height: 8),
                _menuItem('toggle_sidebar', 'Toggle Primary Sidebar', isMac ? '⌘B' : 'Ctrl+B', Icons.vertical_split, wp),
                _menuItem('toggle_panel', 'Toggle Panel', 'Ctrl+`', Icons.horizontal_split, wp),
                _menuItem('toggle_ai', 'Toggle AI Assistant', 'Ctrl+Shift+A', Icons.auto_awesome, wp, const Color(0xFF38BDF8)),
              ],
              wp,
            ),
            _buildMenuButton(
              'Run',
              [
                _menuItem('debug', 'Start Debugging', 'F5', Icons.play_arrow, wp),
                _menuItem('run_web', 'Run Without Debugging', 'Ctrl+F5', Icons.rocket_launch, wp),
              ],
              wp,
            ),
            _buildMenuButton(
              'Terminal',
              [
                _menuItem('new_term', 'New Terminal', 'Ctrl+Shift+`', Icons.terminal, wp),
                _menuItem('build_task', 'Run Build Task', 'Ctrl+Shift+B', Icons.build_circle_outlined, wp),
              ],
              wp,
            ),
            _buildMenuButton(
              'Help',
              [
                _menuItem('about', 'About ${AppConstants.appName}', '', Icons.info_outline, wp, const Color(0xFF38BDF8)),
                _menuItem('shortcuts', 'Keyboard Shortcuts', isMac ? '⌘P' : 'Ctrl+P', Icons.keyboard_outlined, wp),
              ],
              wp,
            ),
          ] else if (!widget.isMobile && !isWide) ...[
            const SizedBox(width: 8),
            _buildMenuButton(
              'Menu',
              [
                _menuItem('open_folder', 'Open Folder...', isMac ? '⌘O' : 'Ctrl+O', Icons.folder_open, wp, const Color(0xFF38BDF8)),
                _menuItem('open_file', 'Open File...', '', Icons.file_upload_outlined, wp),
                const PopupMenuDivider(height: 8),
                _menuItem('palette', 'Command Palette...', isMac ? '⌘P' : 'Ctrl+P', Icons.search, wp),
                _menuItem('toggle_sidebar', 'Toggle Primary Sidebar', isMac ? '⌘B' : 'Ctrl+B', Icons.vertical_split, wp),
                _menuItem('toggle_panel', 'Toggle Panel', 'Ctrl+`', Icons.horizontal_split, wp),
                _menuItem('toggle_ai', 'Toggle AI Assistant', 'Ctrl+Shift+A', Icons.auto_awesome, wp, const Color(0xFF38BDF8)),
                const PopupMenuDivider(height: 8),
                _menuItem('about', 'About ${AppConstants.appName}', '', Icons.info_outline, wp, const Color(0xFF38BDF8)),
              ],
              wp,
            ),
          ],

          // Search Box or Spacer
          if (!widget.isMobile && isMedium) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340, minWidth: 60),
                    child: InkWell(
                      onTap: () => wp.setCommandPaletteOpen(true),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search, size: 13, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${wp.workspaceName} — Search files & commands',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textDim,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                isMac ? '⌘P' : 'Ctrl+P',
                                style: TextStyle(fontSize: 9, color: theme.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            if (!widget.isMobile) ...[
              IconButton(
                icon: const Icon(Icons.search, size: 15),
                color: const Color(0xFF38BDF8),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Search (Ctrl+P)',
                onPressed: () => wp.setCommandPaletteOpen(true),
              ),
              const SizedBox(width: 6),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.search, size: 16),
                color: const Color(0xFF38BDF8),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Search (Ctrl+P)',
                onPressed: () => wp.setCommandPaletteOpen(true),
              ),
              const SizedBox(width: 4),
            ],
          ],

          // Right: Open Folder Quick Button
          if (isWide) ...[
            InkWell(
              onTap: wp.openFolder,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, size: 13, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 4),
                    Text(
                      'Open Folder',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textMain),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Run Badge
          if (!widget.isMobile) ...[
            InkWell(
              onTap: () {
                wp.runTerminalCommand('cargo run');
                if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow, size: 13, color: Color(0xFF10B981)),
                    SizedBox(width: 3),
                    Text('Run', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Layout Toggles
          if (!widget.isMobile) ...[
            IconButton(
              icon: Icon(Icons.vertical_split, size: 15, color: wp.isSidebarOpen ? const Color(0xFF38BDF8) : theme.textDim),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              tooltip: 'Toggle Primary Sidebar (Ctrl+B)',
              onPressed: wp.toggleSidebar,
            ),
            IconButton(
              icon: Icon(Icons.horizontal_split, size: 15, color: wp.isBottomPanelOpen ? const Color(0xFF38BDF8) : theme.textDim),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              tooltip: 'Toggle Bottom Panel (Ctrl+`)',
              onPressed: wp.toggleBottomPanel,
            ),
          ],

          IconButton(
            icon: Icon(Icons.auto_awesome, size: 15, color: wp.isAiPanelOpen ? const Color(0xFF6366F1) : const Color(0xFF818CF8)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            tooltip: 'Toggle AI Copilot (Ctrl+Shift+A)',
            onPressed: wp.toggleAiPanel,
          ),

          // Window Controls (Windows / Linux)
          if (!isMac && !widget.isMobile) ...[
            const SizedBox(width: 4),
            _buildWindowControlButton(
              icon: Icons.minimize,
              iconSize: 13,
              tooltip: 'Minimize',
              theme: theme,
              onTap: _safeMinimize,
            ),
            const SizedBox(width: 2),
            _buildWindowControlButton(
              icon: Icons.crop_square,
              iconSize: 12,
              tooltip: 'Maximize',
              theme: theme,
              onTap: _safeToggleMaximize,
            ),
            const SizedBox(width: 2),
            _buildWindowControlButton(
              icon: Icons.close,
              iconSize: 13,
              tooltip: 'Close',
              isClose: true,
              theme: theme,
              onTap: _safeClose,
            ),
          ],
        ],
      );

      final titleBarContent = Container(
        height: 38,
        decoration: BoxDecoration(
          color: theme.bgSurface,
          border: Border(bottom: BorderSide(color: theme.borderSubtle)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: needsScrollFallback
            ? ClipRect(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: 360,
                    child: titleRow,
                  ),
                ),
              )
            : titleRow,
      );

      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS) && !widget.isMobile) {
        return DragToMoveArea(child: titleBarContent);
      }
      return titleBarContent;
    },
  );
  }

  void _showAboutMingoDialog(BuildContext context, dynamic theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.bgPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.border),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                theme.isDark ? AppConstants.appLogoDarkAsset : AppConstants.appLogoTransparentAsset,
                width: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  AppConstants.appIconAsset,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.code, size: 64, color: Color(0xFF38BDF8)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(fontSize: 12, color: theme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: theme.textDim),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Commit:', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                        Text('v1.0.0-release', style: TextStyle(fontSize: 11, color: theme.textMain, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date:', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                        Text('2026-10-10', style: TextStyle(fontSize: 11, color: theme.textMain)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Architecture:', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                        Text('x64 / ARM64 Universal', style: TextStyle(fontSize: 11, color: theme.textMain)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
