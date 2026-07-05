import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/permission_coordinator.dart';
import '../models/prayer_time.dart';
import '../services/prayer_times_service.dart';
import '../services/reminder_manager.dart';
import '../views/constants/appcolors.dart';
import '../views/constants/appimages.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'prayer_reminder_controller.dart';

class PrayerController extends GetxController with WidgetsBindingObserver {
  final RxString timeRemaining = '00:00:00'.obs;
  final RxString nextPrayer = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString locationError = ''.obs;
  final RxInt asrMethod = 0.obs;
  final RxBool isLoading = true.obs;
  final RxList<PrayerTime> prayerTimes = <PrayerTime>[].obs;
  final RxString loadingStep = 'Starting...'.obs;

  // Prayer check-in state
  final RxMap<String, bool> prayerCheckins = <String, bool>{}.obs;
  final Rx<Set<String>> reachedPrayers = Rx<Set<String>>(<String>{});
  final RxInt completedCount = 0.obs;
  final RxInt streakDays = 0.obs;

  bool _hasLoadedOnce = false;
  Timer? _clockTimer;
  StreamSubscription<Position>? _positionSubscription;

  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  static const List<String> _checkablePrayers = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];
  static const String _asrMethodKey = 'asr_method';
  static const String _checkinDateKey = 'checkin_date';
  static const String _streakKey = 'prayer_streak';
  static const String _streakLastDateKey = 'streak_last_date';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadAsrMethod();
    _requestNotificationPermissions();
    _startClock();
    loadPrayerCheckins();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    _clockTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !PermissionCoordinator().isActive) {
      // Guard: skip if a permission request is in-flight. Android delivers
      // onResume before onRequestPermissionsResult, so firing initLocationService
      // here would submit a second request while the first result is still pending.
      initLocationService();
    }
  }

  // ─── Clock ────────────────────────────────────────────────────────────────

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayer();
    });
  }


Future<void> togglePrayerCheckin(String key) async {
  if (!_checkablePrayers.contains(key)) return;
  final prefs = await SharedPreferences.getInstance();
  final updated = !(prayerCheckins[key] ?? false);
  prayerCheckins[key] = updated;
  prayerCheckins.refresh();
  await prefs.setBool('checkin_$key', updated);

  // Save or clear the check-in timestamp
  if (updated) {
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('checkin_time_$key', now);
  } else {
    await prefs.remove('checkin_time_$key');
  }

  _updateCompletedCount();
  if (completedCount.value == 5) await _checkAndUpdateStreak();
}


  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<void> _requestNotificationPermissions() async {
    try {
      await PermissionCoordinator().run(() async {
        await [
          Permission.notification,
          Permission.scheduleExactAlarm,
        ].request();
      });
    } catch (e) {
      debugPrint('Permission request error (non-fatal): $e');
    }
  }

  // ─── Asr Method ───────────────────────────────────────────────────────────

  Future<void> _loadAsrMethod() async {
    final prefs = await SharedPreferences.getInstance();
    asrMethod.value = prefs.getInt(_asrMethodKey) ?? 0;
  }

  Future<void> _saveAsrMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_asrMethodKey, method);
  }

  void changeAsrMethod(int method) {
    asrMethod.value = method;
    _saveAsrMethod(method);
    fetchPrayerTimes();
  }

  // ─── Reminders ────────────────────────────────────────────────────────────

  Future<void> setNamazEntryAlarm(String assetPath) async {
    final reminderController = Get.isRegistered<PrayerReminderController>()
        ? Get.find<PrayerReminderController>()
        : Get.put(PrayerReminderController());

    final enabledPrayers = reminderController.getEnabledPrayers();
    final notifications = await ReminderManager.createNamazEntryNotifications(
      prayerTimes,
      assetPath,
      enabledPrayers: enabledPrayers,
    );
    await ReminderManager.setMultipleReminders(notifications);
  }

  // ─── Prayer Times ─────────────────────────────────────────────────────────

  Future<void> fetchPrayerTimes() async {
    if (!_hasLoadedOnce) {
      isLoading.value = true;
      loadingStep.value = 'Fetching prayer times…';
    }

    try {
      final times = await _prayerTimesService
          .getPrayerTimesBasedOnLocation(asrMethod.value);
      loadingStep.value = 'Building prayer schedule…';

      if (times.isNotEmpty) {
        prayerTimes.value = [
          PrayerTime(
              name: easy.tr('fajr'),
              time: times['Fajr'] ?? '',
              icon: AppImages.fajr,
              key: 'fajr'),
          PrayerTime(
              name: easy.tr('sunrise'),
              time: times['Sunrise'] ?? '',
              icon: AppImages.sunrise,
              key: 'sunrise'),
          PrayerTime(
              name: easy.tr('dhuhr'),
              time: times['Dhuhr'] ?? '',
              icon: AppImages.sunrise,
              key: 'dhuhr'),
          PrayerTime(
              name: easy.tr('asr'),
              time: times['Asr'] ?? '',
              icon: AppImages.sunrise,
              key: 'asr'),
          PrayerTime(
              name: easy.tr('maghrib'),
              time: times['Maghrib'] ?? '',
              icon: AppImages.maghrib,
              key: 'maghrib'),
          PrayerTime(
              name: easy.tr('isha'),
              time: times['Isha'] ?? '',
              icon: AppImages.isha,
              key: 'isha'),
        ];

        loadingStep.value = 'Calculating next prayer…';
        prayerTimes.sort((a, b) => a.time.compareTo(b.time));
        _updateNextPrayer();

        _hasLoadedOnce = true;
        loadingStep.value = 'Setting reminders…';
        await setNamazEntryAlarm('azan');
      }
    } on SocketException {
      loadingStep.value = 'No internet connection';
    } catch (e) {
      loadingStep.value = 'Error occurred';
      debugPrint('Error fetching prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateNextPrayer() {
    if (prayerTimes.isEmpty) return;

    final now = DateTime.now();
    final currentTimeStr = DateFormat('HH:mm', 'en').format(now);

    // Find the next upcoming prayer
    PrayerTime? next;
    for (final prayer in prayerTimes) {
      if (prayer.time.compareTo(currentTimeStr) > 0) {
        next = prayer;
        break;
      }
    }
    next ??= prayerTimes.first;

    // Update countdown
    final parsed = _parsePrayerTime(next.time);
    if (parsed != null) {
      var nextTime =
          DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
      if (!nextTime.isAfter(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
      final diff = nextTime.difference(now);
      timeRemaining.value = '${diff.inHours.toString().padLeft(2, '0')}:'
          '${(diff.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    nextPrayer.value = next.name;

    // Update which prayers have had their time reached
    final newReached = prayerTimes
        .where((p) =>
            p.key != null &&
            p.key != 'sunrise' &&
            p.time.isNotEmpty &&
            p.time.compareTo(currentTimeStr) <= 0)
        .map((p) => p.key!)
        .toSet();
    if (!setEquals(reachedPrayers.value, newReached)) {
      reachedPrayers.value = newReached;
    }

    // Only reassign the list when which prayer is highlighted changes
    final newCurrentIndex = prayerTimes.indexWhere((p) => p.name == next!.name);
    final oldCurrentIndex = prayerTimes.indexWhere((p) => p.isCurrent);
    if (newCurrentIndex != oldCurrentIndex) {
      prayerTimes.value = prayerTimes.map((p) {
        return p.copyWith(isCurrent: p.name == next!.name);
      }).toList();
    }
  }

  DateTime? _parsePrayerTime(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      return DateFormat('HH:mm', 'en').parse(timeStr.trim());
    } catch (_) {
      return null;
    }
  }

  String getHijriDate() {
    final hijriDate = HijriCalendar.now();
    return '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}';
  }

  // ─── Location ─────────────────────────────────────────────────────────────

  Future<void> initLocationService() async {
    if (latitude.value != 0.0 && longitude.value != 0.0 && _hasLoadedOnce) {
      return;
    }

    try {
      loadingStep.value = 'Checking location service…';
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationError.value = 'Location services are disabled.';
        _showSettingsDialog(
          title: 'Location Service Disabled',
          message:
              'Please enable location services in settings to use Prayer Times and Qibla features.',
          onSettings: Geolocator.openLocationSettings,
        );
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          locationError.value = 'Location services are still disabled.';
          return;
        }
      }

      loadingStep.value = 'Requesting location permission…';
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await PermissionCoordinator()
            .run(() => Geolocator.requestPermission());
        if (permission == LocationPermission.denied) {
          locationError.value = 'Location permissions are denied.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Location permissions are permanently denied.';
        _showSettingsDialog(
          title: 'Location Permission Required',
          message:
              'Location access is required for Prayer Times and Qibla features. Please enable it in app settings.',
          onSettings: Geolocator.openAppSettings,
        );
        return;
      }

      loadingStep.value = 'Getting current location…';
      final position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await fetchPrayerTimes();

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 100,
        ),
      ).listen(
        (Position pos) async {
          latitude.value = pos.latitude;
          longitude.value = pos.longitude;
          locationError.value = '';
          await fetchPrayerTimes();
        },
        onError: (e) {
          debugPrint('Location stream error: $e');
          locationError.value = 'Location unavailable';
        },
      );
    } catch (e) {
      locationError.value = 'Error getting location: $e';
    }
  }

  void _showSettingsDialog({
    required String title,
    required String message,
    required Future<void> Function() onSettings,
  }) {
    final ctx = Get.context!;
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.containerColorThemed(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackTextThemed(ctx),
            ),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.greyTextThemed(ctx),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await onSettings();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Open Settings',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackTextThemed(ctx),
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // ─── Prayer Check-In ──────────────────────────────────────────────────────

  Future<void> loadPrayerCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (prefs.getString(_checkinDateKey) != today) {
      for (final key in _checkablePrayers) {
        await prefs.remove('checkin_$key');
      }
      await prefs.setString(_checkinDateKey, today);
    }

    prayerCheckins.value = {
      for (final key in _checkablePrayers)
        key: prefs.getBool('checkin_$key') ?? false,
    };
    streakDays.value = prefs.getInt(_streakKey) ?? 0;
    _updateCompletedCount();
  }

  // Future<void> togglePrayerCheckin(String key) async {
  //   if (!_checkablePrayers.contains(key)) return;
  //   final prefs = await SharedPreferences.getInstance();
  //   final updated = !(prayerCheckins[key] ?? false);
  //   prayerCheckins[key] = updated;
  //   prayerCheckins.refresh();
  //   await prefs.setBool('checkin_$key', updated);
  //   _updateCompletedCount();
  //   if (completedCount.value == 5) await _checkAndUpdateStreak();
  // }

  void _updateCompletedCount() {
    completedCount.value = prayerCheckins.values.where((v) => v).length;
  }

  Future<void> _checkAndUpdateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    final lastDate = prefs.getString(_streakLastDateKey);

    if (lastDate == today) return;

    final newStreak =
        lastDate == yesterday ? (prefs.getInt(_streakKey) ?? 0) + 1 : 1;

    await prefs.setInt(_streakKey, newStreak);
    await prefs.setString(_streakLastDateKey, today);
    streakDays.value = newStreak;
  }
}
