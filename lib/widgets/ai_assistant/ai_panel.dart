import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../constants/app_constants.dart';

class AIPanel extends StatefulWidget {
  const AIPanel({super.key});

  @override
  State<AIPanel> createState() => _AIPanelState();
}

class _AIPanelState extends State<AIPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _copiedId;

  void _sendMessage(WorkspaceProvider wp) {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      wp.sendAiMessage(text);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    if (!wp.isAiPanelOpen) return const SizedBox.shrink();

    final theme = wp.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = wp.isMobileLayout(screenWidth);
    final panelWidth = isMobile ? math.min(320.0, screenWidth * 0.88) : 320.0;

    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: theme.bgPanel,
        border: Border(left: BorderSide(color: theme.borderSubtle)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              border: Border(bottom: BorderSide(color: theme.borderSubtle)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 15, color: Color(0xFF38BDF8)),
                Flexible(
                  child: Text(
                    AppConstants.aiAssistantName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textMain),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('Ready', style: TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    height: 22,
                    constraints: const BoxConstraints(maxWidth: 110),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: theme.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: wp.aiModel,
                        isExpanded: true,
                        dropdownColor: theme.bgPanel,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8)),
                        icon: const Icon(Icons.arrow_drop_down, size: 13),
                        onChanged: (val) {
                          if (val != null) wp.setAiModel(val);
                        },
                        items: const [
                          DropdownMenuItem(value: AppConstants.defaultAiModel, child: Text('Mingo-1 Pro', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: AppConstants.secondaryAiModel, child: Text('Mingo-Code', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Claude 3.7 Sonnet', child: Text('Claude 3.7', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Local Llama 3 8B', child: Text('Llama 3', overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  onPressed: wp.toggleAiPanel,
                ),
              ],
            ),
          ),

          // Context Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: Colors.black.withValues(alpha: 0.2),
            child: Row(
              children: [
                Text('Context: ', style: TextStyle(fontSize: 10, color: theme.textDim)),
                const Icon(Icons.code, size: 11, color: Color(0xFF38BDF8)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    wp.activeFile?.name ?? 'No file',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '• Git: clean',
                    style: TextStyle(fontSize: 10, color: theme.textDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Chat Feed
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: wp.aiMessages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final msg = wp.aiMessages[index];
                final isUser = msg.role == 'user';

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? theme.accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isUser ? theme.accent.withValues(alpha: 0.3) : theme.borderSubtle,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isUser ? 'You' : (msg.model ?? AppConstants.aiAssistantName),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white : const Color(0xFF38BDF8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(msg.timestamp, style: TextStyle(fontSize: 9, color: theme.textDim)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        msg.content,
                        style: TextStyle(fontSize: 12, color: theme.textMain, height: 1.4),
                      ),

                      // Code snippet
                      if (msg.codeSnippet != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: theme.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    msg.codeSnippet!.language,
                                    style: TextStyle(fontSize: 10, color: theme.textDim, fontFamily: 'monospace'),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: msg.codeSnippet!.code));
                                          setState(() => _copiedId = msg.id);
                                          Future.delayed(const Duration(seconds: 2), () {
                                            if (mounted) setState(() => _copiedId = null);
                                          });
                                        },
                                        child: Icon(
                                          _copiedId == msg.id ? Icons.check : Icons.copy,
                                          size: 12,
                                          color: _copiedId == msg.id ? const Color(0xFF10B981) : theme.textDim,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          final f = wp.activeFile;
                                          if (f != null) {
                                            wp.updateFileContent(f.path, '${f.content}\n\n${msg.codeSnippet!.code}');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Inserted code into ${f.name}')),
                                            );
                                          }
                                        },
                                        child: const Icon(Icons.add_circle_outline, size: 12, color: Color(0xFF38BDF8)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                msg.codeSnippet!.code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Color(0xFFF8FAFC),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Agent Mode Steps
                      if (msg.agentSteps != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'EXECUTION PLAN:',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(height: 4),
                        ...msg.agentSteps!.map((step) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                if (step.status == 'completed')
                                  const Icon(Icons.check_circle, size: 13, color: Color(0xFF10B981))
                                else if (step.status == 'running')
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                                  )
                                else
                                  Icon(Icons.access_time, size: 13, color: theme.textDim),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    step.description,
                                    style: TextStyle(fontSize: 11, color: theme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Security Permission Dialog
                      if (msg.permissionRequest != null && wp.isAgentRunning) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.shield_outlined, size: 13, color: Color(0xFFF59E0B)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Security Confirmation Required',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AI Agent wants to perform action:\n${msg.permissionRequest!.commandOrFile}',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: () => wp.confirmAgentPermission(true),
                                    child: const Text('Allow Once', style: TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(width: 4),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: () => wp.confirmAgentPermission(false),
                                    child: const Text('Deny', style: TextStyle(fontSize: 10)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Quick Chips
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildActionChip('Explain Code', () => wp.sendAiMessage('Explain this code and its architecture'), theme),
                _buildActionChip('Refactor', () => wp.sendAiMessage('Refactor and optimize performance'), theme),
                _buildActionChip('Unit Tests', () => wp.sendAiMessage('Generate comprehensive unit tests'), theme),
                _buildActionChip('Agent: Create File', () => wp.sendAiMessage('Create a new component AuthModal.tsx with tests'), theme),
              ],
            ),
          ),

          // Input Box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              border: Border(top: BorderSide(color: theme.borderSubtle)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _inputController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 12, color: theme.textMain),
                  decoration: InputDecoration(
                    hintText: 'Ask ${AppConstants.aiAssistantName} or describe a task for Agent Mode...',
                    hintStyle: TextStyle(fontSize: 11, color: theme.textDim),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(wp),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.memory, size: 12, color: Color(0xFF38BDF8)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Multi-modal Reasoning',
                              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send, size: 11),
                      label: const Text('Send', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => _sendMessage(wp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap, dynamic theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8))),
        ),
      ),
    );
  }
}
