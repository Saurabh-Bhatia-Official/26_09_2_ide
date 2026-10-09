/// Centralized Application Configuration & Brand Constants.
/// Replaces hardcoded string literals and configuration variables across the IDE.
class AppConstants {
  // Brand & Identification
  static const String appName = 'Mingo IDE';
  static const String appShortName = 'Mingo';
  static const String appLogoLetter = 'M';
  static const String appTagline = 'Cross-Platform Developer Environment';
  static const String appDescription =
      'Fast, modern, intelligent cross-platform developer environment.';
  static const String appVersion = '1.0.0';

  // Theming & Typography
  static const String defaultThemeId = 'gray';
  static const String legacyThemeId = 'nova-dark';
  static const String corporateLightThemeId = 'white-corporate';
  static const String defaultTypography = 'Gray';
  static const double defaultFontSize = 13.5;

  // AI & Assistant
  static const String aiAssistantName = 'Mingo Copilot';
  static const String defaultAiModel = 'Mingo-1 Pro (Cloud)';
  static const String secondaryAiModel = 'Mingo-Code Ultra';

  // User & Accounts
  static const String defaultUserAccount = 'developer@mingo.ide';
  static const String defaultUserTier = 'Pro Tier Active';

  // Defaults & Workspace
  static const String defaultWorkspaceName = 'No Folder Opened';
  static const String defaultWebShellId = 'mingo-sh';
  static const String defaultWebShellName = 'Mingo Shell (Web)';
}
