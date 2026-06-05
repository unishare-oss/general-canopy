import 'package:canopy/core/notifications/notification_service_stub.dart'
    if (dart.library.js_interop) 'package:canopy/core/notifications/notification_service_web.dart'
    as impl;

/// Platform-agnostic local notification facade.
///
/// Web is backed by the browser Notification API
/// (`notification_service_web.dart`); other platforms currently fall back to
/// an unsupported stub until `flutter_local_notifications` is wired up for
/// Android/iOS (tracked in SPEC-0004 follow-ups).
abstract class NotificationService {
  /// Whether this platform can show local notifications at all.
  bool get isSupported;

  /// Asks the platform for notification permission.
  /// Returns true when permission is granted.
  Future<bool> requestPermission();

  /// Shows a local notification immediately. No-op when unsupported or
  /// permission has not been granted.
  Future<void> show({required String title, required String body});
}

NotificationService createNotificationService() =>
    impl.createNotificationService();
