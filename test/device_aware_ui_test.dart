import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:novaide/constants/app_constants.dart';
import 'package:novaide/models/terminal_session.dart';
import 'package:novaide/providers/workspace_provider.dart';
import 'package:novaide/widgets/bottom_panel/terminal_view.dart';
import 'package:novaide/widgets/title_bar.dart';

Widget createTestApp(Widget child, {WorkspaceProvider? provider}) {
  return ChangeNotifierProvider<WorkspaceProvider>(
    create: (_) => provider ?? WorkspaceProvider(),
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('Device-Aware UI & Project Terminal Widget Tests', () {
    testWidgets('TC-18: TitleBar has NO manual device/platform selector dropdown', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final wp = WorkspaceProvider();
      await tester.pumpWidget(createTestApp(const TitleBar(isMobile: false), provider: wp));
      await tester.pump();

      // Ensure NO DropdownButton of any platform exists in TitleBar
      expect(find.descendant(of: find.byType(TitleBar), matching: find.byType(DropdownButton<dynamic>)), findsNothing);
      expect(find.text('💻 Windows (Native)'), findsNothing);
      expect(find.text('Select Device'), findsNothing);
      expect(find.text('WINDOWS'), findsNothing);
      expect(find.text('MAC'), findsNothing);
      expect(find.text('LINUX'), findsNothing);
    });

    testWidgets('TerminalView renders sessions, new terminal button, and project prompt', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final wp = WorkspaceProvider();
      wp.setWorkspacePath(r'C:\Users\Developer\DineMaster');
      wp.createTerminalSession();

      await tester.pumpWidget(createTestApp(const TerminalView(), provider: wp));
      await tester.pump();

      // Check + New Terminal button exists
      expect(find.text('New Terminal'), findsOneWidget);

      // Check active session tab exists
      expect(find.textContaining('2:'), findsWidgets);

      // Check available shell dropdown is rendered with detected shell
      expect(find.byType(DropdownButton<ShellInfo>), findsOneWidget);

      // Check prompt reflects project root
      expect(find.textContaining('DineMaster'), findsWidgets);

      // Click + New Terminal button
      await tester.tap(find.text('New Terminal'));
      await tester.pump();

      // Now 2 sessions should be visible
      expect(find.textContaining('2:'), findsOneWidget);
    });

    testWidgets('Submitting commands in TerminalView updates output buffer', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final wp = WorkspaceProvider();
      await tester.pumpWidget(createTestApp(const TerminalView(), provider: wp));
      await tester.pump();

      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'pwd');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Check that command appears in terminal lines
      expect(find.textContaining('pwd'), findsWidgets);
    });

    testWidgets('TC-17: Theme consistency preserved across views', (tester) async {
      final wp = WorkspaceProvider();
      expect(wp.theme.id, anyOf(AppConstants.defaultThemeId, AppConstants.legacyThemeId));
      expect(wp.theme.bgBase, isNotNull);
      expect(wp.theme.editorBg, isNotNull);
      expect(wp.theme.accent, isNotNull);
    });

    testWidgets('Software is responsive across mobile, tablet, and desktop breakpoints', (tester) async {
      final wp = WorkspaceProvider();

      // 1. Mobile screen (360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createTestApp(const TitleBar(isMobile: true), provider: wp));
      await tester.pump();
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Tablet screen (768 x 1024)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(createTestApp(const TitleBar(isMobile: false), provider: wp));
      await tester.pump();
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Desktop screen (1920 x 1080)
      tester.view.physicalSize = const Size(1920, 1080);
      await tester.pumpWidget(createTestApp(const TitleBar(isMobile: false), provider: wp));
      await tester.pump();
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
