import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:canopy/core/notifications/notification_service.dart';

part 'notification_service_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => createNotificationService();
