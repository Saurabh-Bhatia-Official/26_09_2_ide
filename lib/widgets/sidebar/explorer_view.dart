import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/file_item.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView({super.key});

  @override
  State<ExplorerView> createState() => _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  final Map<String, bool> _expanded = {};

  void _toggleFolder(String id) {
    setState(() {
      _expanded[id] = !(_expanded[id] ?? false);
    });
  }

  void _showNewFileDialog(BuildContext context, WorkspaceProvider wp, [String? folderPath]) {
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
            hintText: 'e.g. index.ts, main.rs',
            hintStyle: TextStyle(color: wp.theme.textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.accent)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              wp.createFile(val.trim(), folderPath);
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
                wp.createFile(controller.text.trim(), folderPath);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context, WorkspaceProvider wp, [String? folderPath]) {
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
              wp.createFolder(val.trim(), folderPath);
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
                wp.createFolder(controller.text.trim(), folderPath);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'rs':
        return const Text('🦀', style: TextStyle(fontSize: 13));
      case 'tsx':
      case 'jsx':
        return const Text('⚛️', style: TextStyle(fontSize: 13));
      case 'ts':
      case 'js':
        return const Icon(Icons.code, size: 14, color: Color(0xFF38BDF8));
      case 'dart':
        return const Text('🎯', style: TextStyle(fontSize: 13));
      case 'py':
        return const Text('🐍', style: TextStyle(fontSize: 13));
      case 'json':
        return const Icon(Icons.data_object, size: 14, color: Color(0xFFFACC15));
      case 'md':
        return const Icon(Icons.description, size: 14, color: Color(0xFF94A3B8));
      case 'css':
        return const Text('🎨', style: TextStyle(fontSize: 13));
      case 'toml':
        return const Text('⚙️', style: TextStyle(fontSize: 13));
      default:
        return const Icon(Icons.insert_drive_file, size: 14, color: Color(0xFF94A3B8));
    }
  }

  Widget _buildTreeItem(BuildContext context, FileItem item, int depth, WorkspaceProvider wp) {
    final theme = wp.theme;
    final isSelected = wp.activeFile?.path == item.path;

    if (item.isFolder) {
      final isExpanded = _expanded[item.id] ?? false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _toggleFolder(item.id),
            child: Container(
              padding: EdgeInsets.only(left: 8.0 + depth * 14.0, right: 8, top: 4, bottom: 4),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 14,
                    color: theme.textDim,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.folder_open : Icons.folder,
                    size: 15,
                    color: const Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(fontSize: 12, color: theme.textMain, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && item.children != null)
            ...item.children!.map((child) => _buildTreeItem(context, child, depth + 1, wp)),
        ],
      );
    }

    // File
    return InkWell(
      onTap: () {
        wp.openFile(item);
        if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
      },
      child: Container(
        color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        padding: EdgeInsets.only(left: 20.0 + depth * 14.0, right: 8, top: 4, bottom: 4),
        child: Row(
          children: [
            _getFileIcon(item.name),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : theme.textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Git Status
            if (item.gitStatus == GitFileStatus.modified)
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: const Text('M', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            if (item.gitStatus == GitFileStatus.untracked)
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: const Text('U', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
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
              Text(
                'Explorer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _iconAction(
                icon: Icons.folder_open,
                color: const Color(0xFF38BDF8),
                tooltip: 'Open Folder from Disk',
                onTap: wp.openFolder,
              ),
              const SizedBox(width: 2),
              _iconAction(
                icon: Icons.note_add_outlined,
                color: theme.textMuted,
                tooltip: 'New File',
                onTap: () => _showNewFileDialog(context, wp),
              ),
              const SizedBox(width: 2),
              _iconAction(
                icon: Icons.create_new_folder_outlined,
                color: theme.textMuted,
                tooltip: 'New Folder',
                onTap: () => _showNewFolderDialog(context, wp),
              ),
            ],
          ),
        ),

        // Quick open buttons
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open, size: 13, color: Color(0xFF38BDF8)),
                  label: const Text('Open Folder', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: theme.accent),
                    ),
                  ),
                  onPressed: wp.openFolder,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.file_upload_outlined, size: 14),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: theme.border),
                  ),
                ),
                tooltip: 'Open Single File',
                onPressed: wp.openSingleFile,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Open Editors
              if (wp.openTabs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'OPEN EDITORS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.textDim,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                ...wp.openTabs.map((tab) {
                  final isActive = wp.activeTabId == tab.id;
                  return InkWell(
                    onTap: () {
                      wp.selectTab(tab.id);
                      if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
                    },
                    child: Container(
                      color: isActive ? Colors.white.withValues(alpha: 0.07) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      child: Row(
                        children: [
                          _getFileIcon(tab.name),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tab.name,
                              style: TextStyle(fontSize: 11, color: isActive ? Colors.white : theme.textMain),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tab.isDirty)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle),
                            ),
                          InkWell(
                            onTap: () => wp.closeTab(tab.id),
                            child: Icon(Icons.close, size: 12, color: theme.textDim),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],

              // Workspace Root Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        wp.workspaceName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.textDim,
                          letterSpacing: 0.6,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      'Local Workspace',
                      style: TextStyle(fontSize: 9, color: Color(0xFF38BDF8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              if (wp.files.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Folder is empty', style: TextStyle(color: theme.textDim, fontSize: 12)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: wp.openFolder,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.border),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Text('Choose another folder', style: TextStyle(color: theme.textMuted, fontSize: 11)),
                      ),
                    ],
                  ),
                )
              else
                ...wp.files.map((f) => _buildTreeItem(context, f, 0, wp)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
