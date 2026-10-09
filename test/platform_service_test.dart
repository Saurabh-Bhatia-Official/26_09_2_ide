import 'package:flutter_test/flutter_test.dart';
import 'package:novaide/models/platform_mode.dart';
import 'package:novaide/services/platform_service.dart';

void main() {
  group('PlatformService PRD Tests (TC-01, TC-02, TC-03)', () {
    tearDown(() {
      PlatformService.setMockPlatform(null);
    });

    test('TC-01: Windows platform detection and helpers', () {
      PlatformService.setMockPlatform(PlatformMode.windows);

      expect(PlatformService.getCurrentPlatform(), PlatformMode.windows);
      expect(PlatformService.platformId, 'windows');
      expect(PlatformService.platformDisplayName, 'Windows');
      expect(PlatformService.isWindows, isTrue);
      expect(PlatformService.isMacOS, isFalse);
      expect(PlatformService.isLinux, isFalse);
      expect(PlatformService.isDesktop, isTrue);
      expect(PlatformService.isMobile, isFalse);
    });

    test('TC-02: macOS platform detection and helpers', () {
      PlatformService.setMockPlatform(PlatformMode.mac);

      expect(PlatformService.getCurrentPlatform(), PlatformMode.mac);
      expect(PlatformService.platformId, 'macos');
      expect(PlatformService.platformDisplayName, 'macOS');
      expect(PlatformService.isWindows, isFalse);
      expect(PlatformService.isMacOS, isTrue);
      expect(PlatformService.isLinux, isFalse);
      expect(PlatformService.isDesktop, isTrue);
      expect(PlatformService.isMobile, isFalse);
    });

    test('TC-03: Linux platform detection and helpers', () {
      PlatformService.setMockPlatform(PlatformMode.linux);

      expect(PlatformService.getCurrentPlatform(), PlatformMode.linux);
      expect(PlatformService.platformId, 'linux');
      expect(PlatformService.platformDisplayName, 'Linux');
      expect(PlatformService.isWindows, isFalse);
      expect(PlatformService.isMacOS, isFalse);
      expect(PlatformService.isLinux, isTrue);
      expect(PlatformService.isDesktop, isTrue);
      expect(PlatformService.isMobile, isFalse);
    });

    test('Mobile platforms (Android and iOS) correctly identified', () {
      PlatformService.setMockPlatform(PlatformMode.android);
      expect(PlatformService.isMobile, isTrue);
      expect(PlatformService.isDesktop, isFalse);
      expect(PlatformService.platformId, 'android');

      PlatformService.setMockPlatform(PlatformMode.ios);
      expect(PlatformService.isMobile, isTrue);
      expect(PlatformService.isDesktop, isFalse);
      expect(PlatformService.platformId, 'ios');
    });

    test('Web platform detection', () {
      PlatformService.setMockPlatform(PlatformMode.web);
      expect(PlatformService.platformId, 'web');
      expect(PlatformService.platformDisplayName, 'Web');
      expect(PlatformService.isDesktop, isFalse);
      expect(PlatformService.isMobile, isFalse);
    });
  });
}
