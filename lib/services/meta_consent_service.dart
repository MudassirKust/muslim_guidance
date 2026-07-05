import 'dart:io';
import 'package:flutter/services.dart';

class MetaConsentService {
  static const _channel = MethodChannel('com.muslimguidance/meta_consent');

  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('initializeMetaAAN');
    } catch (e) {
      // Non-fatal: Meta consent failure should not block ad initialisation
    }
  }
}