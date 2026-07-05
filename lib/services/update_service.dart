import 'package:upgrader/upgrader.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  late final Upgrader upgrader;

  Future<void> initialize() async {
    upgrader = Upgrader(
      debugLogging: false,
      durationUntilAlertAgain: const Duration(days: 1),
    );
    await upgrader.initialize();
  }
}