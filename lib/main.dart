import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/workspace_provider.dart';
import 'models/ide_types.dart';
import 'widgets/title_bar.dart';
import 'widgets/activity_bar.dart';
import 'widgets/status_bar.dart';
import 'widgets/command_palette.dart';
import 'widgets/sidebar/sidebar.dart';
import 'widgets/editor/editor_area.dart';
import 'widgets/bottom_panel/bottom_panel.dart';
import 'widgets/ai_assistant/ai_panel.dart';
import 'widgets/mobile/mobile_nav.dart';
import 'widgets/mobile/mobile_keyboard_bar.dart';
import 'widgets/mobile/mobile_drawer.dart';
import 'constants/app_constants.dart';
import 'widgets/modals/port_preview_modal.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import 'widgets/modals/workspace_trust_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1280, 720),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint('WindowManager initialization: $e');
    }
  }

  runApp(const MingoIDEApp());
}

class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MingoIDEApp extends StatelessWidget {
  final WorkspaceProvider? workspaceProvider;

  const MingoIDEApp({super.key, this.workspaceProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkspaceProvider>(
      create: (_) => workspaceProvider ?? WorkspaceProvider(),
      child: Consumer<WorkspaceProvider>(
        builder: (context, wp, _) {
          final theme = wp.theme;

          return MaterialApp(
            title: '${AppConstants.appName} - ${AppConstants.appTagline}',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const NoScrollbarBehavior(),
            theme: ThemeData(
              brightness: theme.isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: theme.bgBase,
              scrollbarTheme: const ScrollbarThemeData(
                thumbVisibility: WidgetStatePropertyAll<bool>(false),
                trackVisibility: WidgetStatePropertyAll<bool>(false),
                interactive: false,
                thickness: WidgetStatePropertyAll<double>(0.0),
                thumbColor: WidgetStatePropertyAll<Color>(Colors.transparent),
                trackColor: WidgetStatePropertyAll<Color>(Colors.transparent),
                trackBorderColor: WidgetStatePropertyAll<Color>(Colors.transparent),
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.accent,
                brightness: theme.isDark ? Brightness.dark : Brightness.light,
                surface: theme.bgSurface,
              ),
              textTheme: GoogleFonts.interTextTheme(
                theme.isDark
                    ? ThemeData.dark().textTheme
                    : ThemeData.light().textTheme,
              ),
            ),
            home: const MingoIDEMainScreen(),
          );
        },
      ),
    );
  }
}

class MingoIDEMainScreen extends StatelessWidget {
  const MingoIDEMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final theme = wp.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = wp.isMobileLayout(screenWidth);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed;
          final isShift = HardwareKeyboard.instance.isShiftPressed;

          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyP) {
            wp.setCommandPaletteOpen(true);
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyS) {
            wp.saveActiveFile();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyB) {
            wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.backquote) {
            wp.toggleBottomPanel();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.comma) {
            wp.setActivityTab(ActivityTab.settings);
            if (!wp.isSidebarOpen) wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && isShift && event.logicalKey == LogicalKeyboardKey.keyA) {
            wp.toggleAiPanel();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && isShift && event.logicalKey == LogicalKeyboardKey.keyF) {
            wp.setActivityTab(ActivityTab.search);
            if (!wp.isSidebarOpen) wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && isShift && event.logicalKey == LogicalKeyboardKey.keyE) {
            wp.setActivityTab(ActivityTab.explorer);
            if (!wp.isSidebarOpen) wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && isShift && event.logicalKey == LogicalKeyboardKey.keyG) {
            wp.setActivityTab(ActivityTab.git);
            if (!wp.isSidebarOpen) wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && isShift && event.logicalKey == LogicalKeyboardKey.keyX) {
            wp.setActivityTab(ActivityTab.extensions);
            if (!wp.isSidebarOpen) wp.toggleSidebar();
            return KeyEventResult.handled;
          }
          if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyW) {
            if (wp.activeTabId != null) {
              wp.closeTab(wp.activeTabId!);
            }
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.f5) {
            wp.runTerminalCommand('cargo run');
            if (!wp.isBottomPanelOpen) wp.toggleBottomPanel();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: theme.bgBase,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top TitleBar & Menus
                  TitleBar(isMobile: isMobile),

                  // Central Workspace Body
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Desktop Activity Bar & Primary Sidebar
                        if (!isMobile) ...[
                          const ActivityBar(),
                          const Sidebar(),
                        ],

                        // Main Workspace: Editor + Mobile Keyboard Accessory + Bottom Panel
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(child: EditorArea()),
                              if (isMobile) const MobileKeyboardBar(),
                              const BottomPanel(),
                            ],
                          ),
                        ),

                        // AI Copilot & Agent Panel (Desktop & Mobile Slide-over)
                        const AIPanel(),
                      ],
                    ),
                  ),

                  // Bottom Navigation or Desktop Status Bar
                  if (isMobile) const MobileNav() else const StatusBar(),
                ],
              ),

              // Mobile Navigation Slide Drawer
              const MobileDrawer(),

              // Global Overlays & Modals
              const CommandPalette(),
              const PortPreviewModal(),
              const WorkspaceTrustModal(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backwards compatibility alias for NovaIDEApp
typedef NovaIDEApp = MingoIDEApp;
typedef NovaIDEMainScreen = MingoIDEMainScreen;
