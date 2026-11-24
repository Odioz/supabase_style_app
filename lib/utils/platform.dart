import 'package:flutter/foundation.dart';

/// true для смартфонов/планшетов (Android, iOS), false для десктопа и веба.
bool get isMobileDevice {

  if (PlatformDetails().isMobile == true) {
              return true; }{return false; }
}


class PlatformDetails {
  static final PlatformDetails _singleton = PlatformDetails._internal();
  factory PlatformDetails() {
    return _singleton;
  }
  PlatformDetails._internal();
  bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows;
  bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
