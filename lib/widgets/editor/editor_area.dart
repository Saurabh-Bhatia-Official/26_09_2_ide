import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import 'welcome_view.dart';
import 'diff_editor_view.dart';
import 'code_editor_view.dart';

class EditorArea extends StatefulWidget {
  const EditorArea({super.key});

  @override
  State<EditorArea> createState() => _EditorAreaState();
}

class _EditorAreaState extends State<EditorArea> {
  bool _isSplit = false;
  bool _minimapEnabled = true;

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    // Diff view
    if (wp.diffFile != null) {
      return DiffEditorView(
        file: wp.diffFile!,
        onClose: () => wp.setDiffFile(null),
        theme: theme,
      );
    }

    // Welcome view
    final activeFile = wp.activeFile;
    if (wp.openTabs.isEmpty || activeFile == null) {
      return const WelcomeView();
    }

    // Find secondary file for split view
    final secondaryFile = wp.files.length > 1
        ? wp.files.firstWhere(
            (f) => f.path != activeFile.path && !f.isFolder,
            orElse: () => activeFile,
          )
        : activeFile;

    return Column(
      children: [
        // Tabs Bar
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: theme.bgSurface,
            border: Border(bottom: BorderSide(color: theme.borderSubtle)),
          ),
          child: Row(
            children: [
              // Tabs List
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wp.openTabs.length,
                  itemBuilder: (context, index) {
                    final tab = wp.openTabs[index];
                    final isActive = wp.activeTabId == tab.id;

                    return InkWell(
                      onTap: () => wp.selectTab(tab.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isActive ? theme.editorBg : Colors.transparent,
                          border: Border(
                            right: BorderSide(color: theme.borderSubtle),
                            top: BorderSide(
                              color: isActive ? theme.accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.code,
                              size: 13,
                              color: isActive ? const Color(0xFF38BDF8) : theme.textDim,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive ? Colors.white : theme.textMuted,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (tab.isDirty) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => wp.closeTab(tab.id),
                              child: Icon(Icons.close, size: 12, color: theme.textDim),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Actions
              IconButton(
                icon: Icon(Icons.vertical_split, size: 14, color: _isSplit ? const Color(0xFF38BDF8) : theme.textDim),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Split Editor Right',
                onPressed: () => setState(() => _isSplit = !_isSplit),
              ),
              IconButton(
                icon: Icon(Icons.map_outlined, size: 14, color: _minimapEnabled ? const Color(0xFF38BDF8) : theme.textDim),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Toggle Minimap',
                onPressed: () => setState(() => _minimapEnabled = !_minimapEnabled),
              ),
              IconButton(
                icon: Icon(Icons.format_align_left, size: 14, color: theme.textDim),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Format Document (Shift+Alt+F)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Formatted ${activeFile.name} with Prettier/rustfmt')),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),

        // Breadcrumbs Bar
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: theme.editorBg,
            border: Border(bottom: BorderSide(color: theme.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(wp.workspaceName, style: TextStyle(fontSize: 11, color: theme.textDim)),
                      Icon(Icons.chevron_right, size: 12, color: theme.textDim),
                      ...activeFile.path.split('/').map((seg) {
                        final isLast = seg == activeFile.path.split('/').last;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              seg,
                              style: TextStyle(
                                fontSize: 11,
                                color: isLast ? theme.textMain : theme.textDim,
                                fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (!isLast)
                              Icon(Icons.chevron_right, size: 12, color: theme.textDim),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activeFile.language.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Central Editor Viewports
        Expanded(
          child: Row(
            children: [
              // Main Editor
              Expanded(
                child: CodeEditorView(
                  key: ValueKey(activeFile.path),
                  file: activeFile,
                  minimapEnabled: _minimapEnabled,
                  theme: theme,
                  onContentChanged: (newText) {
                    wp.updateFileContent(activeFile.path, newText);
                  },
                ),
              ),

              // Split Editor View
              if (_isSplit) ...[
                Container(width: 1, color: theme.border),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: theme.bgSurface,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${secondaryFile.name} (Split View)',
                          style: TextStyle(fontSize: 11, color: theme.textMuted),
                        ),
                      ),
                      Expanded(
                        child: CodeEditorView(
                          key: ValueKey('split-${secondaryFile.path}'),
                          file: secondaryFile,
                          minimapEnabled: false,
                          theme: theme,
                          onContentChanged: (newText) {
                            wp.updateFileContent(secondaryFile.path, newText);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
