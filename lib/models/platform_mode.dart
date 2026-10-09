enum PlatformMode {
  windows,
  mac,
  linux,
  android,
  ios,
  web,
}

extension PlatformModeExtension on PlatformMode {
  String get name {
    switch (this) {
      case PlatformMode.windows:
        return 'windows';
      case PlatformMode.mac:
        return 'mac';
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

  String get label {
    switch (this) {
      case PlatformMode.windows:
        return '💻 Windows (Native)';
      case PlatformMode.mac:
        return '🍏 macOS (Darwin)';
      case PlatformMode.linux:
        return '🐧 Linux (X11/Wayland)';
      case PlatformMode.android:
        return '📱 Android (APK Client)';
      case PlatformMode.ios:
        return '🍎 iOS (Mobile Client)';
      case PlatformMode.web:
        return '🌐 Web (PWA Browser)';
    }
  }

  static PlatformMode fromString(String val) {
    switch (val.toLowerCase()) {
      case 'mac':
        return PlatformMode.mac;
      case 'linux':
        return PlatformMode.linux;
      case 'android':
        return PlatformMode.android;
      case 'ios':
        return PlatformMode.ios;
      case 'web':
        return PlatformMode.web;
      case 'windows':
      default:
        return PlatformMode.windows;
    }
  }
}
