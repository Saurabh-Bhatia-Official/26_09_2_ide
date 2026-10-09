import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../models/platform_mode.dart';

/// Centralized platform detection service.
/// Automatically detects the host operating system without user intervention.
class PlatformService {
  static PlatformMode? _cachedPlatform;

  /// Detects and returns the current platform.
  /// Detection is executed once and cached, with graceful fallback on error.
  static PlatformMode getCurrentPlatform() {
    if (_cachedPlatform != null) {
      return _cachedPlatform!;
    }

    if (kIsWeb) {
      _cachedPlatform = PlatformMode.web;
      debugPrint('[INFO] Platform detected: web');
      return _cachedPlatform!;
    }

    try {
      if (Platform.isMacOS) {
        _cachedPlatform = PlatformMode.mac;
        debugPrint('[INFO] Platform detected: macos');
      } else if (Platform.isLinux) {
        _cachedPlatform = PlatformMode.linux;
        debugPrint('[INFO] Platform detected: linux');
      } else if (Platform.isAndroid) {
        _cachedPlatform = PlatformMode.android;
        debugPrint('[INFO] Platform detected: android');
      } else if (Platform.isIOS) {
        _cachedPlatform = PlatformMode.ios;
        debugPrint('[INFO] Platform detected: ios');
      } else if (Platform.isWindows) {
        _cachedPlatform = PlatformMode.windows;
        debugPrint('[INFO] Platform detected: windows');
      } else {
        _cachedPlatform = PlatformMode.windows;
        debugPrint('[WARN] Unknown platform detected. Falling back to windows default.');
      }
    } catch (e) {
      debugPrint('[WARN] Error during platform detection: $e. Falling back to windows.');
      _cachedPlatform = PlatformMode.windows;
    }

    return _cachedPlatform!;
  }

  /// Sets an override platform mode for testing or mock environments.
  @visibleForTesting
  static void setMockPlatform(PlatformMode? mode) {
    _cachedPlatform = mode;
  }

  /// Platform ID string matching PRD Table in Section 4.
  static String get platformId {
    switch (getCurrentPlatform()) {
      case PlatformMode.windows:
        return 'windows';
      case PlatformMode.mac:
        return 'macos';
      case PlatformMode.linux:
        return 'linux';
      case PlatformMode.android:
        return 'android';
      case PlatformMode.ios:
        return 'ios';
      case PlatformMode.web:
        return 'web';
    }
  }

  /// Human-readable platform name.
  static String get platformDisplayName {
    switch (getCurrentPlatform()) {
      case PlatformMode.windows:
        return 'Windows';
      case PlatformMode.mac:
        return 'macOS';
      case PlatformMode.linux:
        return 'Linux';
      case PlatformMode.android:
        return 'Android';
      case PlatformMode.ios:
        return 'iOS';
      case PlatformMode.web:
        return 'Web';
    }
  }

  static bool get isWindows => getCurrentPlatform() == PlatformMode.windows;
  static bool get isMacOS => getCurrentPlatform() == PlatformMode.mac;
  static bool get isLinux => getCurrentPlatform() == PlatformMode.linux;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isMobile =>
      getCurrentPlatform() == PlatformMode.android ||
      getCurrentPlatform() == PlatformMode.ios;
}
