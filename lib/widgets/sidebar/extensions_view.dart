import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';

class ExtensionsView extends StatefulWidget {
  const ExtensionsView({super.key});

  @override
  State<ExtensionsView> createState() => _ExtensionsViewState();
}

class _ExtensionsViewState extends State<ExtensionsView> {
  String _search = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Languages', 'AI', 'Themes', 'Linters', 'Tools'];

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;

    final filtered = wp.extensions.where((ext) {
      final matchesSearch = ext.displayName.toLowerCase().contains(_search.toLowerCase()) ||
          ext.description.toLowerCase().contains(_search.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || ext.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

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
            'Extensions: Marketplace',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Search & Filter
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
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
                          hintText: 'Search extensions in marketplace...',
                          hintStyle: TextStyle(fontSize: 11, color: theme.textDim),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => setState(() => _search = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Category chips
              SizedBox(
                height: 24,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSel = _selectedCategory == cat;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSel ? theme.accent : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSel ? Colors.white : theme.textMuted,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => Divider(color: theme.borderSubtle, height: 1),
            itemBuilder: (context, index) {
              final ext = filtered[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(ext.icon, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ext.displayName,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textMain),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ext.installed ? Colors.white.withValues(alpha: 0.08) : theme.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                ),
                                onPressed: () => wp.toggleInstallExtension(ext.id),
                                child: Text(ext.installed ? 'Disable' : 'Install', style: const TextStyle(fontSize: 10)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ext.description,
                            style: TextStyle(fontSize: 11, color: theme.textMuted, height: 1.3),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ext.publisher,
                                  style: TextStyle(fontSize: 10, color: theme.textDim),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.download, size: 10, color: theme.textDim),
                              const SizedBox(width: 2),
                              Text(ext.downloads, style: TextStyle(fontSize: 10, color: theme.textDim)),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, size: 10, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text('${ext.rating}', style: TextStyle(fontSize: 10, color: theme.textDim)),
                            ],
                          ),
                        ],
                      ),
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
