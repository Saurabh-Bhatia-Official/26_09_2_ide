import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/file_item.dart';
import '../../providers/workspace_provider.dart';
import '../../utils/code_text_controller.dart';

class CodeEditorView extends StatefulWidget {
  final FileItem file;
  final bool minimapEnabled;
  final ValueChanged<String> onContentChanged;
  final dynamic theme;

  const CodeEditorView({
    super.key,
    required this.file,
    required this.minimapEnabled,
    required this.onContentChanged,
    required this.theme,
  });

  @override
  State<CodeEditorView> createState() => _CodeEditorViewState();
}

class _CodeEditorViewState extends State<CodeEditorView> {
  late CodeTextController _controller;
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _gutterScroll = ScrollController();

  String _resolveFont(String family) {
    switch (family) {
      case 'Gray':
        return 'monospace';
      case 'JetBrains Mono':
        return 'JetBrains Mono, monospace';
      case 'Fira Code':
        return 'Fira Code, monospace';
      case 'Roboto Mono':
        return 'Roboto Mono, monospace';
      case 'Inter':
        return 'Inter, sans-serif';
      case 'Consolas':
        return 'Consolas, monospace';
      default:
        return 'monospace';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CodeTextController(
      text: widget.file.content,
      language: widget.file.language,
      isDark: widget.theme.isDark,
    );
    _controller.addListener(_onTextChanged);
    _verticalScroll.addListener(_syncGutterScroll);
  }

  void _syncGutterScroll() {
    if (_gutterScroll.hasClients && _verticalScroll.hasClients) {
      if (_gutterScroll.offset != _verticalScroll.offset) {
        _gutterScroll.jumpTo(_verticalScroll.offset.clamp(0.0, _gutterScroll.position.maxScrollExtent));
      }
    }
  }

  @override
  void didUpdateWidget(covariant CodeEditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
      _controller = CodeTextController(
        text: widget.file.content,
        language: widget.file.language,
        isDark: widget.theme.isDark,
      );
      _controller.addListener(_onTextChanged);
    } else if (oldWidget.theme.isDark != widget.theme.isDark) {
      _controller.isDark = widget.theme.isDark;
    }
  }

  void _onTextChanged() {
    if (_controller.text != widget.file.content) {
      widget.onContentChanged(_controller.text);
    }
    setState(() {}); // Update line numbers and minimap
  }

  @override
  void dispose() {
    _verticalScroll.removeListener(_syncGutterScroll);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    _gutterScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = widget.theme;
    final fontSize = wp.fontSize;
    final fontFamily = wp.fontFamily;
    final isWordWrap = wp.wordWrap;
    final linesCount = '\n'.allMatches(_controller.text).length + 1;
    final lineHeight = fontSize * 1.45;

    return Container(
      color: theme.editorBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Line Numbers Gutter
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.bgSurface.withValues(alpha: 0.5),
              border: Border(right: BorderSide(color: theme.borderSubtle)),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _gutterScroll,
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(linesCount, (index) {
                    return Container(
                      height: lineHeight,
                      padding: const EdgeInsets.only(right: 8),
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: (fontSize - 1.5).clamp(9.0, 30.0),
                          fontFamily: _resolveFont(fontFamily),
                          color: theme.textDim,
                          height: 1.45,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Code Text Field (Scrollbar removed, no visible scrollbars)
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: isWordWrap
                  ? SingleChildScrollView(
                      controller: _verticalScroll,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        cursorColor: const Color(0xFF38BDF8),
                        cursorWidth: 2,
                        style: TextStyle(
                          fontFamily: _resolveFont(fontFamily),
                          fontSize: fontSize,
                          color: fontFamily == 'Gray' ? const Color(0xFFABB2BF) : theme.textMain,
                          height: 1.45,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _verticalScroll,
                      child: SingleChildScrollView(
                        controller: _horizontalScroll,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 400),
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              cursorColor: const Color(0xFF38BDF8),
                              cursorWidth: 2,
                              style: TextStyle(
                                fontFamily: _resolveFont(fontFamily),
                                fontSize: fontSize,
                                color: fontFamily == 'Gray' ? const Color(0xFFABB2BF) : theme.textMain,
                                height: 1.45,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // Minimap View
          if (widget.minimapEnabled) ...[
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: theme.bgSurface.withValues(alpha: 0.4),
                border: Border(left: BorderSide(color: theme.borderSubtle)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Opacity(
                opacity: 0.6,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _controller.text.split('\n').take(60).map((line) {
                      final len = line.trim().length.clamp(1, 30);
                      return Container(
                        height: 3,
                        width: len * 2.0,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: line.trim().startsWith('//')
                              ? theme.textDim
                              : (line.trim().startsWith('fn') || line.trim().startsWith('import')
                                  ? const Color(0xFF38BDF8)
                                  : theme.textMuted),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
        ],
      ),
    );
  }
}
