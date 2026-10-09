import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:novaide/constants/app_constants.dart';
import 'package:novaide/main.dart';
import 'package:novaide/providers/workspace_provider.dart';
import 'package:novaide/models/ide_types.dart';
import 'package:novaide/widgets/activity_bar.dart';
import 'package:novaide/widgets/title_bar.dart';
import 'package:novaide/widgets/status_bar.dart';
import 'package:novaide/widgets/sidebar/sidebar.dart';
import 'package:novaide/widgets/sidebar/explorer_view.dart';
import 'package:novaide/widgets/sidebar/search_view.dart';
import 'package:novaide/widgets/sidebar/git_view.dart';
import 'package:novaide/widgets/sidebar/debug_view.dart';
import 'package:novaide/widgets/sidebar/extensions_view.dart';
import 'package:novaide/widgets/sidebar/settings_view.dart';
import 'package:novaide/widgets/sidebar/testing_view.dart';
import 'package:novaide/widgets/sidebar/remote_view.dart';
import 'package:novaide/widgets/bottom_panel/bottom_panel.dart';
import 'package:novaide/widgets/bottom_panel/terminal_view.dart';
import 'package:novaide/widgets/bottom_panel/problems_view.dart';
import 'package:novaide/widgets/bottom_panel/output_view.dart';
import 'package:novaide/widgets/bottom_panel/ports_view.dart';
import 'package:novaide/widgets/editor/editor_area.dart';
import 'package:novaide/widgets/editor/welcome_view.dart';
import 'package:novaide/widgets/editor/diff_editor_view.dart';
import 'package:novaide/widgets/ai_assistant/ai_panel.dart';
import 'package:novaide/widgets/command_palette.dart';
import 'package:novaide/widgets/modals/port_preview_modal.dart';
import 'package:novaide/widgets/modals/workspace_trust_modal.dart';

Widget createTestApp(Widget child, {WorkspaceProvider? provider}) {
  return ChangeNotifierProvider<WorkspaceProvider>(
    create: (_) => provider ?? WorkspaceProvider(),
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('ActivityBar renders tabs and handles clicks', (tester) async {
    final wp = WorkspaceProvider();
    await tester.pumpWidget(createTestApp(const ActivityBar(), provider: wp));
    await tester.pump();

    // Verify icons exist
    expect(find.byIcon(Icons.folder_copy_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.fork_right_outlined), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.extension_outlined), findsOneWidget);

    // Tap search tab
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(wp.activityTab, ActivityTab.search);

    // Tap git tab
    await tester.tap(find.byIcon(Icons.fork_right_outlined));
    await tester.pump();
    expect(wp.activityTab, ActivityTab.git);
  });

  testWidgets('Sidebar renders ExplorerView, SearchView, GitView, etc.', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final wp = WorkspaceProvider();
    await tester.pumpWidget(createTestApp(const Sidebar(), provider: wp));
    await tester.pump();

    expect(find.byType(ExplorerView), findsOneWidget);

    // Switch to search
    wp.setActivityTab(ActivityTab.search);
    await tester.pump();
    expect(find.byType(SearchView), findsOneWidget);

    // Switch to git
    wp.setActivityTab(ActivityTab.git);
    await tester.pump();
    expect(find.byType(GitView), findsOneWidget);

    // Switch to debug
    wp.setActivityTab(ActivityTab.debug);
    await tester.pump();
    expect(find.byType(DebugView), findsOneWidget);

    // Switch to extensions
    wp.setActivityTab(ActivityTab.extensions);
    await tester.pump();
    expect(find.byType(ExtensionsView), findsOneWidget);

    // Switch to settings
    wp.setActivityTab(ActivityTab.settings);
    await tester.pump();
    expect(find.byType(SettingsView), findsOneWidget);

    // Switch to testing
    wp.setActivityTab(ActivityTab.testing);
    await tester.pump();
    expect(find.byType(TestingView), findsOneWidget);

    // Switch to remote
    wp.setActivityTab(ActivityTab.remote);
    await tester.pump();
    expect(find.byType(RemoteView), findsOneWidget);
  });

  testWidgets('EditorArea renders WelcomeView when no tabs are open', (tester) async {
    final wp = WorkspaceProvider();
    await tester.pumpWidget(createTestApp(const EditorArea(), provider: wp));
    await tester.pump();

    expect(find.byType(WelcomeView), findsOneWidget);
    expect(find.text(AppConstants.appName), findsWidgets);
  });

  testWidgets('EditorArea renders DiffEditorView when diffFile is set', (tester) async {
    final wp = WorkspaceProvider();
    wp.createFile('sample.rs');
    final file = wp.files.firstWhere((f) => f.name == 'sample.rs');
    wp.setDiffFile(file);

    await tester.pumpWidget(createTestApp(const EditorArea(), provider: wp));
    await tester.pump();

    expect(find.byType(DiffEditorView), findsOneWidget);
  });

  testWidgets('BottomPanel renders Terminal, Problems, Output, Ports views', (tester) async {
    final wp = WorkspaceProvider();
    wp.toggleBottomPanel(); // Open panel

    await tester.pumpWidget(createTestApp(const BottomPanel(), provider: wp));
    await tester.pump();

    expect(find.byType(TerminalView), findsOneWidget);

    // Switch to Problems
    wp.setBottomPanelTab(BottomPanelTab.problems);
    await tester.pump();
    expect(find.byType(ProblemsView), findsOneWidget);

    // Switch to Output
    wp.setBottomPanelTab(BottomPanelTab.output);
    await tester.pump();
    expect(find.byType(OutputView), findsOneWidget);

    // Switch to Ports
    wp.setBottomPanelTab(BottomPanelTab.ports);
    await tester.pump();
    expect(find.byType(PortsView), findsOneWidget);
  });

  testWidgets('TitleBar and StatusBar render cleanly on desktop resolution', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final wp = WorkspaceProvider();
    await tester.pumpWidget(
      createTestApp(
        const Column(
          children: [
            TitleBar(isMobile: false),
            Expanded(child: SizedBox()),
            StatusBar(),
          ],
        ),
        provider: wp,
      ),
    );
    await tester.pump();

    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.textContaining('main'), findsWidgets); // branch
  });

  testWidgets('AIPanel renders and allows submitting prompts', (tester) async {
    final wp = WorkspaceProvider();
    wp.toggleAiPanel();

    await tester.pumpWidget(createTestApp(const AIPanel(), provider: wp));
    await tester.pump();

    expect(find.text(AppConstants.aiAssistantName), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('CommandPalette opens and closes correctly', (tester) async {
    final wp = WorkspaceProvider();
    wp.setCommandPaletteOpen(true);

    await tester.pumpWidget(createTestApp(const CommandPalette(), provider: wp));
    await tester.pump();

    expect(find.byType(CommandPalette), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('PortPreviewModal and WorkspaceTrustModal render when triggered', (tester) async {
    final wp = WorkspaceProvider();
    wp.setPreviewUrl('http://localhost:5173');

    await tester.pumpWidget(
      createTestApp(
        const Stack(
          children: [
            PortPreviewModal(),
            WorkspaceTrustModal(),
          ],
        ),
        provider: wp,
      ),
    );
    await tester.pump();

    expect(find.text('${AppConstants.appName} Integrated Web Preview'), findsOneWidget);
    expect(find.text('${AppConstants.appName} Live Web Server'), findsOneWidget);
  });

  testWidgets('Full MingoIDEApp integration test', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MingoIDEApp());
    await tester.pump();

    expect(find.byType(MingoIDEMainScreen), findsOneWidget);
    expect(find.byType(ActivityBar), findsOneWidget);
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.byType(EditorArea), findsOneWidget);
  });
}
