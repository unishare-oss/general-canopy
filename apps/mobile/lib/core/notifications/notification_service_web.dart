import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'package:canopy/core/notifications/notification_service.dart';

/// Browser Notification API implementation. Requires a secure context
/// (https or localhost); [isSupported] is false otherwise.
class _WebNotificationService implements NotificationService {
  const _WebNotificationService();

  @override
  bool get isSupported => web.window.has('Notification');

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    if (web.Notification.permission == 'granted') return true;
    if (web.Notification.permission == 'denied') return false;
    final result = await web.Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  @override
  Future<void> show({required String title, required String body}) async {
    if (!isSupported || web.Notification.permission != 'granted') return;
    web.Notification(title, web.NotificationOptions(body: body));
  }
}

NotificationService createNotificationService() =>
    const _WebNotificationService();
