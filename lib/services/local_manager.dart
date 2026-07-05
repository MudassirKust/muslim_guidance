import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager {
  static const String _localeKey = 'locale';
  static const String _translationEditionKey = 'translation_edition';
  static const String _appOpenCountKey = 'app_open_count';
  static const String _lastReadSurahKey = 'last_read_surah';
  static const String _lastReadParahKey = 'last_read_parah';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _paywallShownKey = 'paywall_shown';

  static Future<void> saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  static Future<String?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> saveTranslationEdition(String edition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationEditionKey, edition);
  }

  static Future<String> loadTranslationEdition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_translationEditionKey) ?? 'en.sahih';
  }

  static Future<void> incrementAppOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_appOpenCountKey) ?? 0) + 1;
    await prefs.setInt(_appOpenCountKey, count);
  }

  static Future<bool> isThirdLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_appOpenCountKey) ?? 0;
    return count > 0 && count % 3 == 0;
  }

  static Future<void> saveLastReadSurah({
    required int surahNumber,
    required String surahName,
    required int verseIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadSurahKey, jsonEncode({
      'surahNumber': surahNumber,
      'surahName': surahName,
      'verseIndex': verseIndex,
    }));
  }

  static Future<Map<String, dynamic>?> loadLastReadSurah() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastReadSurahKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveLastReadParah({
    required int juzNumber,
    required String commonName,
    required int verseIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadParahKey, jsonEncode({
      'juzNumber': juzNumber,
      'commonName': commonName,
      'verseIndex': verseIndex,
    }));
  }

  static Future<Map<String, dynamic>?> loadLastReadParah() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastReadParahKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> saveOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> isPaywallShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_paywallShownKey) ?? false;
  }

  static Future<void> savePaywallShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_paywallShownKey, true);
  }
}
