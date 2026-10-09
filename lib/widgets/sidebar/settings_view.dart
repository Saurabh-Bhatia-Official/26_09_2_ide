import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../data/themes_data.dart';
import '../../constants/app_constants.dart';
import '../../models/ide_types.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    const typographyOptions = [
      'Gray',
      'JetBrains Mono',
      'Fira Code',
      'Inter',
      'Roboto Mono',
      'Consolas',
      'Monospace',
    ];

    const fontSizePresets = [11.0, 12.0, 13.5, 15.0, 16.0, 18.0];

    final keyMappings = [
      {
        'action': 'Search Files & Commands',
        'shortcut': 'Ctrl+P',
        'category': 'Navigation',
        'icon': Icons.search,
        'onTap': () => wp.setCommandPaletteOpen(true),
      },
      {
        'action': 'Command Palette (Commands)',
        'shortcut': 'Ctrl+Shift+P',
        'category': 'Navigation',
        'icon': Icons.terminal,
        'onTap': () => wp.setCommandPaletteOpen(true),
      },
      {
        'action': 'Save Active File',
        'shortcut': 'Ctrl+S',
        'category': 'Editor',
        'icon': Icons.save_outlined,
        'onTap': () => wp.saveActiveFile(),
      },
      {
        'action': 'Toggle Primary Sidebar',
        'shortcut': 'Ctrl+B',
        'category': 'View',
        'icon': Icons.vertical_split,
        'onTap': () => wp.toggleSidebar(),
      },
      {
        'action': 'Toggle Integrated Terminal',
        'shortcut': 'Ctrl+`',
        'category': 'View',
        'icon': Icons.horizontal_split,
        'onTap': () => wp.toggleBottomPanel(),
      },
      {
        'action': 'Open Settings',
        'shortcut': 'Ctrl+,',
        'category': 'Preferences',
        'icon': Icons.settings_outlined,
        'onTap': () => wp.setActivityTab(ActivityTab.settings),
      },
      {
        'action': 'Toggle Mingo AI Copilot',
        'shortcut': 'Ctrl+Shift+A',
        'category': 'AI',
        'icon': Icons.auto_awesome,
        'onTap': () => wp.toggleAiPanel(),
      },
      {
        'action': 'Find in Files (Search)',
        'shortcut': 'Ctrl+Shift+F',
        'category': 'Navigation',
        'icon': Icons.find_in_page_outlined,
        'onTap': () {
          wp.setActivityTab(ActivityTab.search);
          if (!wp.isSidebarOpen) wp.toggleSidebar();
        },
      },
      {
        'action': 'File Explorer',
        'shortcut': 'Ctrl+Shift+E',
        'category': 'Navigation',
        'icon': Icons.folder_outlined,
        'onTap': () {
          wp.setActivityTab(ActivityTab.explorer);
          if (!wp.isSidebarOpen) wp.toggleSidebar();
        },
      },
      {
        'action': 'Source Control (Git)',
        'shortcut': 'Ctrl+Shift+G',
        'category': 'Git',
        'icon': Icons.fork_right,
        'onTap': () {
          wp.setActivityTab(ActivityTab.git);
          if (!wp.isSidebarOpen) wp.toggleSidebar();
        },
      },
      {
        'action': 'Extensions Marketplace',
        'shortcut': 'Ctrl+Shift+X',
        'category': 'Extensions',
        'icon': Icons.extension_outlined,
        'onTap': () {
          wp.setActivityTab(ActivityTab.extensions);
          if (!wp.isSidebarOpen) wp.toggleSidebar();
        },
      },
      {
        'action': 'Close Active Tab',
        'shortcut': 'Ctrl+W',
        'category': 'Editor',
        'icon': Icons.close,
        'onTap': () {
          if (wp.activeTabId != null) wp.closeTab(wp.activeTabId!);
        },
      },
      {
        'action': 'Run Project Task',
        'shortcut': 'F5',
        'category': 'Run',
        'icon': Icons.play_arrow,
        'onTap': () {
          wp.runTerminalCommand('cargo run');
          if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
        },
      },
      {
        'action': 'Open Folder',
        'shortcut': 'Ctrl+O',
        'category': 'File',
        'icon': Icons.folder_open,
        'onTap': () => wp.openFolder(),
      },
    ];

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
            'Preferences & Settings',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Search Files & Commands Quick Launcher
              InkWell(
                onTap: () => wp.setCommandPaletteOpen(true),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search Files & Commands...',
                          style: TextStyle(fontSize: 12, color: theme.textDim),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Ctrl+P',
                          style: TextStyle(fontSize: 9, color: theme.textMuted, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Theme section
              Row(
                children: [
                  Icon(Icons.palette_outlined, size: 14, color: theme.accent),
                  const SizedBox(width: 6),
                  Text('Theme & Colors', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain)),
                ],
              ),
              const SizedBox(height: 8),

              ...ThemesData.allThemes.values
                  .where((t) => t.id != 'nova-dark' && t.id != 'corporate-white')
                  .map((t) {
                final isSelected = wp.themeId == t.id;
                return InkWell(
                  onTap: () => wp.setThemeId(t.id),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.accent.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSelected ? theme.accent : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: t.bgBase,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: t.accent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : theme.textMain,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, size: 14, color: theme.accent),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Font Typography Section
              Row(
                children: [
                  const Icon(Icons.font_download_outlined, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Font Typography',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      wp.fontFamily,
                      style: TextStyle(fontSize: 10, color: theme.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: typographyOptions.contains(wp.fontFamily) ? wp.fontFamily : 'Gray',
                    isExpanded: true,
                    dropdownColor: theme.bgPanel,
                    style: TextStyle(fontSize: 11, color: theme.textMain),
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    onChanged: (val) {
                      if (val != null) wp.setFontFamily(val);
                    },
                    items: typographyOptions.map((font) {
                      return DropdownMenuItem<String>(
                        value: font,
                        child: Text(
                          font == 'Gray' ? 'Gray (Default - Corporate Monospace)' : font,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: font == 'Gray' ? 'monospace' : font,
                            color: font == wp.fontFamily ? theme.accent : theme.textMain,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Font Size Section
              Row(
                children: [
                  const Icon(Icons.format_size, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Font Size',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                    ),
                  ),
                  Text(
                    '${wp.fontSize.toStringAsFixed(1)} px',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.accent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    color: theme.textMain,
                    onPressed: () {
                      final newSize = (wp.fontSize - 0.5).clamp(9.0, 26.0);
                      wp.setFontSize(newSize);
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        activeTrackColor: theme.accent,
                        inactiveTrackColor: theme.border,
                        thumbColor: theme.accent,
                      ),
                      child: Slider(
                        value: wp.fontSize.clamp(9.0, 24.0),
                        min: 9.0,
                        max: 24.0,
                        divisions: 30,
                        onChanged: (val) => wp.setFontSize(val),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    color: theme.textMain,
                    onPressed: () {
                      final newSize = (wp.fontSize + 0.5).clamp(9.0, 26.0);
                      wp.setFontSize(newSize);
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: fontSizePresets.map((size) {
                  final isCurrent = (wp.fontSize - size).abs() < 0.2;
                  return InkWell(
                    onTap: () => wp.setFontSize(size),
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrent ? theme.accent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: isCurrent ? theme.accent : theme.borderSubtle),
                      ),
                      child: Text(
                        '${size.toStringAsFixed(size.truncateToDouble() == size ? 0 : 1)}px',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? theme.accent : theme.textDim,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Work Wrap (Word Wrap) Section
              Row(
                children: [
                  const Icon(Icons.wrap_text, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Work Wrap (Word Wrap)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: wp.wordWrap
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      wp.wordWrap ? 'Enabled' : 'Off',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: wp.wordWrap ? const Color(0xFF10B981) : theme.textDim,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: wp.toggleWordWrap,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: wp.wordWrap ? theme.accent : theme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: wp.wordWrap,
                          activeColor: theme.accent,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (val) {
                            if (val != null) wp.setWordWrap(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wrap code lines to editor width',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textMain),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'When active, lines wrap automatically without horizontal scroll.',
                              style: TextStyle(fontSize: 10, color: theme.textDim),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Key Mapping & Shortcuts Section
              Row(
                children: [
                  const Icon(Icons.keyboard, size: 14, color: Color(0xFFA855F7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Key Mapping & Shortcuts',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.borderSubtle),
                ),
                child: Column(
                  children: keyMappings.map((km) {
                    return InkWell(
                      onTap: km['onTap'] as VoidCallback,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: theme.borderSubtle.withValues(alpha: 0.5))),
                        ),
                        child: Row(
                          children: [
                            Icon(km['icon'] as IconData, size: 13, color: theme.textDim),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                km['action'] as String,
                                style: TextStyle(fontSize: 11, color: theme.textMain),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: theme.borderSubtle),
                              ),
                              child: Text(
                                km['shortcut'] as String,
                                style: TextStyle(fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: theme.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // AI Model section
              Row(
                children: [
                  const Icon(Icons.memory, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI Copilot & Models',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: wp.aiModel,
                    isExpanded: true,
                    dropdownColor: theme.bgPanel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    onChanged: (val) {
                      if (val != null) wp.setAiModel(val);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.defaultAiModel,
                        child: Text('${AppConstants.appShortName}-1 Pro (Cloud Turbo - 1M Context)'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.secondaryAiModel,
                        child: Text('${AppConstants.appShortName}-Code Ultra (Optimized Engine)'),
                      ),
                      DropdownMenuItem(
                        value: 'Claude 3.7 Sonnet',
                        child: Text('Claude 3.7 Sonnet (Hybrid Reasoning)'),
                      ),
                      DropdownMenuItem(
                        value: 'Local Llama 3 8B',
                        child: Text('Local Llama 3 8B (On-Device GPU)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security & Trust
              Row(
                children: [
                  const Icon(Icons.security, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Security & Trust',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => wp.setWorkspaceTrusted(!wp.isWorkspaceTrusted),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: wp.isWorkspaceTrusted,
                        activeColor: theme.accent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          if (val != null) wp.setWorkspaceTrusted(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trust this workspace (Enables tasks, debug, extensions)',
                        style: TextStyle(fontSize: 11, color: theme.textMain),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
