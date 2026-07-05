import 'dart:async';

/// Ensures only one permission request runs at a time across the app.
/// Prevents "A request for permissions is already running" crash when
/// splash, PrayerController, PrayerTimesService, etc. request permissions.
class PermissionCoordinator {
  static final PermissionCoordinator _instance = PermissionCoordinator._internal();
  factory PermissionCoordinator() => _instance;
  PermissionCoordinator._internal();

  Completer<void>? _currentRequest;

  /// True while a permission request is in-flight.
  /// Use this to avoid triggering a new request during didChangeAppLifecycleState
  /// before Android has finished delivering the current result.
  bool get isActive => _currentRequest != null;

  /// Run a permission request. Waits for any in-progress request to finish first.
  Future<T> run<T>(Future<T> Function() request) async {
    // Wait for any existing request to complete
    while (_currentRequest != null) {
      await _currentRequest!.future;
    }

    final completer = Completer<void>();
    _currentRequest = completer;

    try {
      final result = await request();
      return result;
    } finally {
      completer.complete();
      if (_currentRequest == completer) {
        _currentRequest = null;
      }
    }
  }
}
