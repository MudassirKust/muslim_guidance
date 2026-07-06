import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:islamlearning/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/local_manager.dart';
import 'services/reminder_manager.dart';
import 'controllers/theme_controller.dart';
import 'services/app_review_service.dart';
import 'services/ad_service.dart';
import 'services/revenue_cat_service.dart';
import 'services/update_service.dart';
import 'controllers/ad_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/subscription_controller.dart';

//Locale locale=const Locale('en');
@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bundle fonts with app - don't fetch from network at runtime
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics: app opened
  await AppReviewService.logAppOpened();
  await LocaleManager.incrementAppOpenCount();

  // Crashlytics - catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Crashlytics - catch async errors (Futures/Streams) outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Enable performance monitoring
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  await EasyLocalization.ensureInitialized();
  await ReminderManager.initializeNotifications();
  await SharedPreferences.getInstance();
  await RevenueCatService.instance.initialize();
  await AdService.instance.initialize();
  await UpdateService.instance.initialize();

  // Initialize JustAudioBackground for background audio playback
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.muslimguidance.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: false,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e, stack) {
    FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
  }
 
  //Get.put(PrayerController());
  final savedLanguage = await LocaleManager.loadLocale();
  final startLocale =
      savedLanguage != null ? Locale(savedLanguage) : const Locale('en');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('fr'),
        Locale('nl'),
        Locale('es'),
        Locale('sv'),
        Locale('no'),
        Locale('fi'),
        Locale('ps'),
        Locale('id'),
        Locale('tr'),
        Locale('de'),
        Locale('bn'),
        Locale('so'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    Get.put(SubscriptionController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(AdController(), permanent: true);

    // GetMaterialApp resolves `Get.locale ?? locale`; keep Get.locale in
    // sync with easy_localization so the stale static can never win.
    Get.locale = context.locale;

    return GetMaterialApp(
      title: 'Muslim Guidance',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        _FallbackLocalizationDelegate(),
      ],
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: ThemeMode.system, // Automatically detect system theme
      home: const SplashScreen(),
    );
  }
}

class _FallbackLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) {
    // Support all locales - fallback to English for unsupported ones
    return true;
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // For unsupported locales like Somali (so) and Bengali (bn), fall back to English
    const fallbackLocale = Locale('en', 'US');

    // Check if the locale is supported by Flutter
    const supportedLocales = [
      'en',
      'ar',
      'ur',
      'fr',
      'nl',
      'es',
      'sv',
      'no',
      'fi',
      'id',
      'tr',
      'de'
    ];

    if (supportedLocales.contains(locale.languageCode)) {
      return await GlobalMaterialLocalizations.delegate.load(locale);
    } else {
      // Fall back to English for unsupported locales
      return await GlobalMaterialLocalizations.delegate.load(fallbackLocale);
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) {
    return false;
  }
}
