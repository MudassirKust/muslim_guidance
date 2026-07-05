import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:in_app_review/in_app_review.dart';

class AppReviewService {
  static Future<void> logAppOpened() async {
    await _logEvent('app_opened');
  }

  static Future<void> logHomeLoaded() async {
    await _logEvent('home_loaded');
  }

  static Future<void> scheduleReviewIfNeeded({
    required bool Function() isOnHomeScreen,
  }) async {
    await _logEvent('review_timer_started');

    await Future.delayed(const Duration(seconds: 15));

    if (!isOnHomeScreen()) return;

    final inAppReview = InAppReview.instance;

    final isAvailable = await inAppReview.isAvailable();
    if (!isAvailable) return;

    await _logEvent('review_popup_requested');

    try {
      await inAppReview.requestReview();
      await _logEvent('review_popup_shown');
    } catch (_) {
      // Review API failures should never crash the app.
    }
  }

  static Future<void> _logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (_) {
      // Analytics failures should never crash the app.
    }
  }
}

