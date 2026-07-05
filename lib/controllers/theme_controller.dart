import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Always default to light theme
    _isDarkMode.value = false;
    await prefs.setBool('isDarkMode', false);
  }
  
  // Remove toggle functionality since we only want light theme
  // Future<void> toggleTheme() async {
  //   _isDarkMode.value = !_isDarkMode.value;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isDarkMode', _isDarkMode.value);
  //   
  //   // Update the app theme
  //   Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  // }
  
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: const Color(0xffFAF8F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffFAF8F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff2F9E92)),
        titleTextStyle: TextStyle(
          color: Color(0xff2F9E92),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xffF9F2DF),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xffFFFFFF),
        selectedItemColor: Color(0xff2F9E92),
        unselectedItemColor: Color(0xff9D9D9D),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xffF0EDE7),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xff000000)),
        bodyMedium: TextStyle(color: Color(0xff587677)),
        titleLarge: TextStyle(color: Color(0xff2F9E92)),
      ),
    );
  }
  
  // Keep dark theme for potential future use but don't expose it
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: const Color(0xff1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1A1A1A),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff2F9E92)),
        titleTextStyle: TextStyle(
          color: Color(0xff2F9E92),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xff2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff2D2D2D),
        selectedItemColor: Color(0xff2F9E92),
        unselectedItemColor: Color(0xff9D9D9D),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xff404040),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xffFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xffB0B0B0)),
        titleLarge: TextStyle(color: Color(0xff2F9E92)),
      ),
    );
  }
}
