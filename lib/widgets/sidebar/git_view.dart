import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/file_item.dart';

class GitView extends StatefulWidget {
  const GitView({super.key});

  @override
  State<GitView> createState() => _GitViewState();
}

class _GitViewState extends State<GitView> {
  final TextEditingController _commitController = TextEditingController();
  bool _isGeneratingAiMsg = false;

  @override
  void dispose() {
    _commitController.dispose();
    super.dispose();
  }

  void _generateAiCommit(WorkspaceProvider wp) {
    setState(() => _isGeneratingAiMsg = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isGeneratingAiMsg = false;
          _commitController.text =
              'feat(rust-engine): optimize incremental AST indexing and LSP multiplexer';
          wp.setCommitMessage(_commitController.text);
        });
      }
    });
  }

  void _showNewBranchDialog(BuildContext context, WorkspaceProvider wp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: wp.theme.bgSurface,
        title: Text('New Branch', style: TextStyle(color: wp.theme.textMain, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: wp.theme.textMain, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Branch name...',
            hintStyle: TextStyle(color: wp.theme.textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: wp.theme.accent)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              wp.createBranch(val.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: wp.theme.textDim))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: wp.theme.accent),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                wp.createBranch(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  FileItem? _findFile(List<FileItem> items, String path) {
    for (final it in items) {
      if (it.path == path) return it;
      if (it.children != null) {
        final f = _findFile(it.children!, path);
        if (f != null) return f;
      }
    }
    return null;
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
                  'Source Control: Git',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.sync, size: 14),
                color: theme.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Fetch Changes',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fetched latest changes from origin/main')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.cloud_sync_outlined, size: 14),
                color: theme.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Sync Changes',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synced with remote repository.')),
                  );
                },
              ),
            ],
          ),
        ),

        // Branch and commit controls
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Branch selector
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fork_right, size: 14, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: wp.currentBranch,
                                dropdownColor: theme.bgPanel,
                                isDense: true,
                                style: TextStyle(fontSize: 12, color: theme.textMain, fontWeight: FontWeight.w600),
                                icon: const Icon(Icons.arrow_drop_down, size: 14),
                                onChanged: (val) {
                                  if (val != null) wp.setCurrentBranch(val);
                                },
                                items: wp.branches
                                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.add, size: 14),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: theme.border),
                      ),
                    ),
                    tooltip: 'New Branch',
                    onPressed: () => _showNewBranchDialog(context, wp),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Commit Message Input
              Stack(
                children: [
                  TextField(
                    controller: _commitController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 12, color: theme.textMain),
                    decoration: InputDecoration(
                      hintText: 'Commit message (Ctrl+Enter to commit)...',
                      hintStyle: TextStyle(fontSize: 11, color: theme.textDim),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.accent),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    ),
                    onChanged: wp.setCommitMessage,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => _generateAiCommit(wp),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: theme.accent),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: _isGeneratingAiMsg ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Commit buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 13),
                      label: Text(
                        'Commit (${wp.stagedFiles.length})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: wp.stagedFiles.isEmpty || wp.commitMessage.trim().isEmpty
                          ? null
                          : () => wp.commitChanges(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.publish, size: 14),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: theme.border),
                      ),
                    ),
                    tooltip: 'Commit & Push',
                    onPressed: () {
                      wp.commitChanges();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pushed commit to origin/${wp.currentBranch}')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Changes list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // Staged changes
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STAGED CHANGES (${wp.stagedFiles.length})',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textMuted),
                    ),
                    if (wp.stagedFiles.isNotEmpty)
                      InkWell(
                        onTap: () {
                          final copy = List<String>.from(wp.stagedFiles);
                          for (final f in copy) {
                            wp.unstageFile(f);
                          }
                        },
                        child: Icon(Icons.remove, size: 13, color: theme.textDim),
                      ),
                  ],
                ),
              ),
              ...wp.stagedFiles.map((path) {
                return InkWell(
                  onTap: () {
                    final f = _findFile(wp.files, path);
                    if (f != null) {
                      wp.setDiffFile(f);
                      if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 13, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(path, style: TextStyle(fontSize: 11, color: theme.textMain), overflow: TextOverflow.ellipsis)),
                        const Text('M', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => wp.unstageFile(path),
                          child: Icon(Icons.remove, size: 13, color: theme.textDim),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Unstaged changes
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CHANGES (${wp.unstagedFiles.length})',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textMuted),
                    ),
                    InkWell(
                      onTap: wp.stageAll,
                      child: Icon(Icons.add, size: 13, color: theme.textDim),
                    ),
                  ],
                ),
              ),
              ...wp.unstagedFiles.map((path) {
                return InkWell(
                  onTap: () {
                    final f = _findFile(wp.files, path);
                    if (f != null) {
                      wp.setDiffFile(f);
                      if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(path, style: TextStyle(fontSize: 11, color: theme.textMain), overflow: TextOverflow.ellipsis)),
                        const Text('M', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => wp.stageFile(path),
                          child: Icon(Icons.add, size: 13, color: theme.textDim),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Recent commits
              if (wp.gitHistory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    'RECENT COMMITS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textDim),
                  ),
                ),
                ...wp.gitHistory.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.commit, size: 12, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                c.message,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textMain),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '${c.hash} • ${c.date}',
                            style: TextStyle(fontSize: 10, color: theme.textDim, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
