import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:islamlearning/models/prayer_time.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_model.dart';

class ReminderManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    /*var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );*/

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {},
    );
  }

  static Future<void> setMultipleReminders(
      List<NotificationModel> notifications) async {
    for (var notification in notifications) {
      debugPrint(
          "112233, notification time: ${DateFormat("hh:mm dd-MM-yyyy").format(notification.schedule)}");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.schedule, tz.local),
        NotificationDetails(
          android: notification.android,
          iOS: notification.ios,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<List<NotificationModel>> createNamazEntryNotifications(
      List<PrayerTime> data, String assetPath,
      {List<String>? enabledPrayers}) async {
    List<NotificationModel> notifications = [];
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    int idCounter = 400;

    for (var prayer in data) {
      if (enabledPrayers != null &&
          prayer.key != null &&
          !enabledPrayers.contains(prayer.key)) {
        continue;
      }

      DateTime? prayerDateTime;
      try {
        prayerDateTime = DateFormat("HH:mm").parse(prayer.time.trim());
      } catch (_) {
        continue; // Skip this prayer if time format is invalid
      }
      DateTime scheduledDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        prayerDateTime.hour,
        prayerDateTime.minute,
      );

      if (idCounter >= 430) break;

      addNotificationIfFuture(
        notifications,
        scheduledDateTime,
        idCounter,
        '${prayer.name} Prayer Reminder',
        assetPath,
        'It\'s time for ${prayer.name} prayer.',
        idCounter++,
      );
    }

    return notifications;
  }

  static Future<void> addNotificationIfFuture(
    List<NotificationModel> notifications,
    DateTime currentDate,
    int timing,
    String title,
    String assetPath,
    String body,
    int idCounter,
  ) async {
    DateTime notificationTime = currentDate;
    debugPrint('Scheduled created: $idCounter : $notificationTime');

    if (notificationTime.isAfter(DateTime.now()) ||
        notificationTime.isAtSameMomentAs(DateTime.now())) {
      notifications.add(NotificationModel(
        id: idCounter,
        title: title,
        body: body,
        schedule: notificationTime,
        android: AndroidNotificationDetails(
          "$assetPath channel",
          '$assetPath channel',
          channelDescription: body,
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(assetPath),
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableLights: true,
          autoCancel: false,
        ),
        ios: DarwinNotificationDetails(
          sound: "$assetPath.wav",
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ));
    }
  }
}
