import 'package:flutter/foundation.dart';

/// true для смартфонов/планшетов (Android, iOS), false для десктопа и веба.
bool get isMobileDevice {
  if (kIsWeb) {
    // На вебе ориентируемся на ширину окна: узкое — считаем мобильным
    return false; // веб всегда показываем как десктоп (номер + копирование)
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}