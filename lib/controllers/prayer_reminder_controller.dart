import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_controller.dart';

class PrayerReminderController extends GetxController {
  // Observable variables for each prayer reminder setting
  final RxBool fajrReminder = true.obs;
  final RxBool dhuhrReminder = true.obs;
  final RxBool asrReminder = true.obs;
  final RxBool maghribReminder = true.obs;
  final RxBool ishaReminder = true.obs;

  // Observable variable for reminder time (minutes before prayer)
  final RxInt reminderTime = 5.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrayerReminderSettings();
  }

  Future<void> loadPrayerReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    fajrReminder.value = prefs.getBool('fajr_reminder') ?? true;
    dhuhrReminder.value = prefs.getBool('dhuhr_reminder') ?? true;
    asrReminder.value = prefs.getBool('asr_reminder') ?? true;
    maghribReminder.value = prefs.getBool('maghrib_reminder') ?? true;
    ishaReminder.value = prefs.getBool('isha_reminder') ?? true;
    reminderTime.value = prefs.getInt('reminder_time') ?? 5;
  }

  Future<void> toggleFajrReminder() async {
    fajrReminder.value = !fajrReminder.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fajr_reminder', fajrReminder.value);
    await _refreshNotifications();
  }

  Future<void> toggleDhuhrReminder() async {
    dhuhrReminder.value = !dhuhrReminder.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dhuhr_reminder', dhuhrReminder.value);
    await _refreshNotifications();
  }

  Future<void> toggleAsrReminder() async {
    asrReminder.value = !asrReminder.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asr_reminder', asrReminder.value);
    await _refreshNotifications();
  }

  Future<void> toggleMaghribReminder() async {
    maghribReminder.value = !maghribReminder.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('maghrib_reminder', maghribReminder.value);
    await _refreshNotifications();
  }

  Future<void> toggleIshaReminder() async {
    ishaReminder.value = !ishaReminder.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isha_reminder', ishaReminder.value);
    await _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    if (Get.isRegistered<PrayerController>()) {
      final prayerController = Get.find<PrayerController>();
      await prayerController.setNamazEntryAlarm('azan');
    }
  }

  Future<void> setReminderTime(int minutes) async {
    reminderTime.value = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_time', reminderTime.value);
  }

  // Get reminder status for a specific prayer
  bool getReminderStatus(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajrReminder.value;
      case 'dhuhr':
        return dhuhrReminder.value;
      case 'asr':
        return asrReminder.value;
      case 'maghrib':
        return maghribReminder.value;
      case 'isha':
        return ishaReminder.value;
      default:
        return false;
    }
  }

  // Get all enabled prayers
  List<String> getEnabledPrayers() {
    List<String> enabledPrayers = [];
    if (fajrReminder.value) enabledPrayers.add('fajr');
    if (dhuhrReminder.value) enabledPrayers.add('dhuhr');
    if (asrReminder.value) enabledPrayers.add('asr');
    if (maghribReminder.value) enabledPrayers.add('maghrib');
    if (ishaReminder.value) enabledPrayers.add('isha');
    return enabledPrayers;
  }
}






