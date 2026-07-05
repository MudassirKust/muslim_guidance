import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  RxString selectedLanguage = 'English'.obs;

  final Rx<Locale> currentLocale = const Locale('en').obs;
  final RxBool hasExplicitlySelectedLanguage = false.obs;
  final RxString appVersion = 'Loading...'.obs;

  Map<String, Locale> get languageMap => {
    'English': const Locale('en'),
    'العربية': const Locale('ar'), // Arabic
    'اردو': const Locale('ur'), // Urdu
    'Français': const Locale('fr'), // French
    'Nederlands': const Locale('nl'), // Dutch
    'Español': const Locale('es'), // Spanish
    'Svenska': const Locale('sv'), // Swedish
    'Norsk': const Locale('no'), // Norwegian
    'Suomi': const Locale('fi'), // Finnish
    'پښتو': const Locale('ps'), // Pashto
    'Bahasa': const Locale('id'), // Indonesian
    'Türkçe': const Locale('tr'), // Turkish
    'Deutsch': const Locale('de'), // German
    'বাংলা': const Locale('bn'), // Bengali
    'Soomaali': const Locale('so'), // Somali
  };
  final List<String> languages = [
    easy.tr('lang_english'),
    easy.tr('lang_arabic'),
    easy.tr('lang_urdu'),
    easy.tr('lang_french'),
    easy.tr('lang_dutch'),
    easy.tr('lang_spanish'),
    easy.tr('lang_swedish'),
    easy.tr('lang_norwegian'),
    easy.tr('lang_finnish'),
    easy.tr('lang_pashto'),
    easy.tr('lang_indonesian'), // Updated key
    easy.tr('lang_turkish'),
    easy.tr('lang_german'),
    easy.tr('lang_bengali'),
    easy.tr('lang_somali'),
  ];

  @override
  void onInit() {
    super.onInit();
    _initPackageInfo();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedCode = await LocaleManager.loadLocale();
    if (savedCode != null) {
      final matchedEntry = languageMap.entries.firstWhere(
        (entry) => entry.value.languageCode == savedCode,
        orElse: () => const MapEntry('English', Locale('en')),
      );
      currentLocale.value = matchedEntry.value;
      hasExplicitlySelectedLanguage.value = true;
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    currentLocale.value = newLocale;
    hasExplicitlySelectedLanguage.value = true;
    // Keep GetX in sync without Get.updateLocale(): its forceAppUpdate()
    // flips MaterialApp.locale before easy_localization has loaded the new
    // translations, which prevents the new language from applying until restart.
    // NOTE: callers must invoke this BEFORE context.setLocale() — GetMaterialApp
    // builds with `Get.locale ?? locale`, so Get.locale has to be updated before
    // easy_localization schedules the app-level rebuild (see language_screen.dart).
    Get.locale = newLocale;
    await LocaleManager.saveLocale(newLocale.languageCode);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
  }

  Future<void> launchContactEmail(BuildContext context) async {
    const email = 'medinacreationsx@gmail.com';
    final uri = Uri.parse('mailto:$email');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to Gmail web if native email app fails
        final gmailUri =
            Uri.parse('https://mail.google.com/mail/?view=cm&to=$email');
        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri);
        } else {
          throw Exception('No email client available');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }
}
