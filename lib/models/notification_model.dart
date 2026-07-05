
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime schedule;
  final AndroidNotificationDetails android;
  final DarwinNotificationDetails ios;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.schedule,
    required this.android,
    required this.ios,
  });
}