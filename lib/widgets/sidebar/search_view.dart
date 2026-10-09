import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/file_item.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  bool _isReplaceOpen = false;
  bool _matchCase = false;
  bool _matchWholeWord = false;
  bool _useRegex = false;

  List<FileItem> _flatten(List<FileItem> items) {
    final List<FileItem> res = [];
    for (final item in items) {
      if (!item.isFolder) {
        res.add(item);
      } else if (item.children != null) {
        res.addAll(_flatten(item.children!));
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final allFiles = _flatten(wp.files);

    final List<Map<String, dynamic>> results = [];

    if (wp.searchQuery.trim().isNotEmpty) {
      for (final file in allFiles) {
        final lines = file.content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          bool isMatch = false;

          if (_useRegex) {
            try {
              final reg = RegExp(wp.searchQuery, caseSensitive: _matchCase);
              isMatch = reg.hasMatch(line);
            } catch (_) {
              isMatch = false;
            }
          } else if (_matchWholeWord) {
            final reg = RegExp(r'\b' + RegExp.escape(wp.searchQuery) + r'\b',
                caseSensitive: _matchCase);
            isMatch = reg.hasMatch(line);
          } else {
            isMatch = _matchCase
                ? line.contains(wp.searchQuery)
                : line.toLowerCase().contains(wp.searchQuery.toLowerCase());
          }

          if (isMatch) {
            results.add({
              'file': file,
              'line': i + 1,
              'content': line.trim(),
            });
          }
        }
      }
    }

    // Group by file path
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final r in results) {
      final f = r['file'] as FileItem;
      grouped.putIfAbsent(f.path, () => []).add(r);
    }

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
                  'Search & Replace',
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
                icon: Icon(Icons.find_replace, size: 14, color: _isReplaceOpen ? const Color(0xFF38BDF8) : theme.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Toggle Replace',
                onPressed: () => setState(() => _isReplaceOpen = !_isReplaceOpen),
              ),
            ],
          ),
        ),

        // Search and replace inputs
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search input
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 13, color: theme.textDim),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 12, color: theme.textMain),
                        decoration: InputDecoration(
                          hintText: 'Search workspace...',
                          hintStyle: TextStyle(fontSize: 11, color: theme.textDim),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: wp.setSearchQuery,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _matchCase = !_matchCase),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          'Aa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _matchCase ? const Color(0xFF38BDF8) : theme.textDim,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() => _matchWholeWord = !_matchWholeWord),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          'ab',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: _matchWholeWord ? const Color(0xFF38BDF8) : theme.textDim,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() => _useRegex = !_useRegex),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          '.*',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _useRegex ? const Color(0xFF38BDF8) : theme.textDim,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Replace input
              if (_isReplaceOpen) ...[
                const SizedBox(height: 6),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.find_replace, size: 13, color: theme.textDim),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          style: TextStyle(fontSize: 12, color: theme.textMain),
                          decoration: InputDecoration(
                            hintText: 'Replace with...',
                            hintStyle: TextStyle(fontSize: 11, color: theme.textDim),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: wp.setReplaceQuery,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Replaced occurrences with "${wp.replaceQuery}"')),
                          );
                        },
                        child: const Text('Replace', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 6),
              Text(
                wp.searchQuery.isNotEmpty
                    ? '${results.length} results in ${grouped.keys.length} files'
                    : 'Type to search workspace code',
                style: TextStyle(fontSize: 11, color: theme.textDim),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: grouped.entries.map((entry) {
              final file = entry.value.first['file'] as FileItem;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      wp.openFile(file);
                      if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.keyboard_arrow_down, size: 14, color: theme.textDim),
                          const SizedBox(width: 4),
                          Text(file.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '(${file.path})',
                              style: TextStyle(fontSize: 10, color: theme.textDim),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${entry.value.length}',
                              style: TextStyle(fontSize: 9, color: theme.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...entry.value.map((res) {
                    return InkWell(
                      onTap: () {
                        wp.openFile(file);
                        if (wp.isMobileDrawerOpen) wp.setMobileDrawerOpen(false);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 6, top: 3, bottom: 3),
                        child: Row(
                          children: [
                            Text(
                              '${res['line']}: ',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontFamily: 'monospace'),
                            ),
                            Expanded(
                              child: Text(
                                res['content'] as String,
                                style: TextStyle(fontSize: 11, color: theme.textMuted, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
