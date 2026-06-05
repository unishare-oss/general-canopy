import 'package:canopy/core/notifications/notification_service.dart';

/// Fallback for platforms without a local-notification backend yet
/// (Android/iOS support is a SPEC-0004 follow-up).
class _UnsupportedNotificationService implements NotificationService {
  const _UnsupportedNotificationService();

  @override
  bool get isSupported => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show({required String title, required String body}) async {}
}

NotificationService createNotificationService() =>
    const _UnsupportedNotificationService();
