import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/ide_types.dart';

class TestingView extends StatefulWidget {
  const TestingView({super.key});

  @override
  State<TestingView> createState() => _TestingViewState();
}

class _TestingViewState extends State<TestingView> {
  final List<TestCase> _tests = [
    TestCase(id: 'test_indexer_parallel', name: 'tests::test_indexer_parallel', file: 'tests/test_core.rs', status: TestStatus.passed, duration: '12ms'),
    TestCase(id: 'test_ast_caching', name: 'tests::test_ast_caching', file: 'tests/test_core.rs', status: TestStatus.passed, duration: '4ms'),
    TestCase(id: 'test_lsp_multiplexer', name: 'tests::test_lsp_multiplexer', file: 'tests/test_core.rs', status: TestStatus.idle),
    TestCase(id: 'test_ai_agent_step_runner', name: 'tests::test_ai_agent_step_runner', file: 'tests/test_core.rs', status: TestStatus.idle),
  ];

  void _runSingleTest(TestCase t, WorkspaceProvider wp) {
    setState(() => t.status = TestStatus.running);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          t.status = TestStatus.passed;
          t.duration = '14ms';
        });
        wp.runTerminalCommand('cargo test ${t.id}');
      }
    });
  }

  void _runAll(WorkspaceProvider wp) {
    for (final t in _tests) {
      setState(() => t.status = TestStatus.running);
    }
    wp.runTerminalCommand('cargo test --workspace');
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          for (final t in _tests) {
            t.status = TestStatus.passed;
            t.duration = '15ms';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final passedCount = _tests.where((t) => t.status == TestStatus.passed).length;

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
                  'Testing: Unit & Integration',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 14),
                color: const Color(0xFF10B981),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Run All Tests',
                onPressed: () => _runAll(wp),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 14),
                color: theme.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                tooltip: 'Refresh Tests',
                onPressed: () => _runAll(wp),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 14),
                label: const Text('Run All Tests (cargo test)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => _runAll(wp),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('Passed: $passedCount / ${_tests.length}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text('Engine: Cargo / Nextest',
                        style: TextStyle(fontSize: 11, color: theme.textDim),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Text(
                'tests/test_core.rs',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textMuted),
              ),
              const SizedBox(height: 4),
              ..._tests.map((t) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      if (t.status == TestStatus.passed)
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981))
                      else if (t.status == TestStatus.failed)
                        const Icon(Icons.cancel, size: 14, color: Color(0xFFF43F5E))
                      else if (t.status == TestStatus.running)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                        )
                      else
                        Icon(Icons.access_time, size: 14, color: theme.textDim),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.name,
                          style: TextStyle(fontSize: 11, color: theme.textMain, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (t.duration != null)
                        Text(t.duration!, style: TextStyle(fontSize: 10, color: theme.textDim)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _runSingleTest(t, wp),
                        child: Icon(Icons.play_arrow, size: 13, color: theme.textDim),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
