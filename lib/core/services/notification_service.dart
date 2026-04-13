import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_strings.dart';
import '../../features/home/domain/models/wish_item_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'wish_reminders';
  static const _channelName = AppStrings.notifChannelName;
  static const _channelDesc = AppStrings.notifChannelDesc;

  // 정확한 알람 권한 캐시 — initialize() 후 결정됨
  bool _canExact = false;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // Android 13+ 알림 권한 요청
      await androidImpl.requestNotificationsPermission();

      // Android 12+ 정확한 알람 권한 요청 (설정 화면으로 이동)
      // 사용자가 거부해도 inexact 모드로 폴백하므로 결과는 무시
      await androidImpl.requestExactAlarmsPermission();

      // 실제 권한 부여 여부 확인 후 캐시
      _canExact =
          await androidImpl.canScheduleExactNotifications() ?? false;
    }

    debugPrint('[NotificationService] 정확한 알람 권한: $_canExact');
  }

  // itemId 기반으로 충돌 없는 알림 ID 생성 (offset: 0=24h, 1=48h, 2=72h)
  int _notificationId(String itemId, int offset) =>
      (itemId.hashCode.abs() % 333333) * 10 + offset;

  Future<void> scheduleWishNotifications(WishItem item) async {
    final milestones = [
      (
        offset: 0,
        delay: const Duration(hours: 24),
        title: AppStrings.notif24hTitle,
        body: AppStrings.notif24hBody(item.name),
      ),
      (
        offset: 1,
        delay: const Duration(hours: 48),
        title: AppStrings.notif48hTitle,
        body: AppStrings.notif48hBody(item.name),
      ),
      (
        offset: 2,
        delay: const Duration(hours: 72),
        title: AppStrings.notif72hTitle,
        body: AppStrings.notif72hBody(item.name),
      ),
    ];

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // 권한 있으면 정확한 알람, 없으면 inexact 폴백 (72h 타이머는 몇 분 오차 허용)
    final scheduleMode = _canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final now = tz.TZDateTime.now(tz.local);

    for (final m in milestones) {
      final scheduledAt = tz.TZDateTime.from(
        item.createdAt.add(m.delay),
        tz.local,
      );
      if (scheduledAt.isBefore(now)) continue; // 이미 지난 시간은 스킵

      try {
        await _plugin.zonedSchedule(
          _notificationId(item.id, m.offset),
          m.title,
          m.body,
          scheduledAt,
          details,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: item.id,
        );
      } catch (e) {
        debugPrint('[NotificationService] 알림 예약 실패: $e');
      }
    }
  }

  Future<void> cancelWishNotifications(String itemId) async {
    await _plugin.cancel(_notificationId(itemId, 0));
    await _plugin.cancel(_notificationId(itemId, 1));
    await _plugin.cancel(_notificationId(itemId, 2));
  }
}
