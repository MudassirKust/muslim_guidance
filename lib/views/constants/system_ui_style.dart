// lib/config/system_ui_style.dart

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SystemUIConfig {
  static const lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Color(0xFFFFFDF7),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static void applyLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(lightStatusBar);
  }

  static void applyDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(darkStatusBar);
  }
}
