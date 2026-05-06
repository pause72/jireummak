import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

  // TODO: 테스트 완료 후 false로 변경
  static const _testMode = false;

  bool _canExact = false;

  Future<void> initialize() async {
    // ── 타임존 초기화 (기기의 실제 로컬 타임존 설정) ──────
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('[NotificationService] 타임존: $timeZoneName');
    } catch (e) {
      debugPrint('[NotificationService] 타임존 설정 실패, UTC 사용: $e');
    }

    // ── Android 초기화 ─────────────────────────────────────
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // ── iOS 초기화 (포그라운드 알림 표시 포함) ───────────────
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // 포그라운드에서도 알림 표시
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] 알림 탭: ${details.payload}');
      },
    );

    // ── iOS 권한 명시적 요청 ──────────────────────────────
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[NotificationService] iOS 알림 권한: $granted');
    }

    // ── Android 권한 요청 ─────────────────────────────────
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
      _canExact =
          await androidImpl.canScheduleExactNotifications() ?? false;
      debugPrint('[NotificationService] 정확한 알람 권한: $_canExact');
    }
  }

  // itemId 기반으로 충돌 없는 알림 ID 생성
  int _notificationId(String itemId) => itemId.hashCode.abs() % 999999;

  Future<void> scheduleWishNotifications(WishItem item) async {
    // 프로덕션: 72h / 테스트: 1m
    final delay = _testMode
        ? const Duration(minutes: 1)
        : const Duration(hours: 72);

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final scheduleMode = _canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final now = tz.TZDateTime.now(tz.local);
    final targetTime = item.createdAt.add(delay);
    final scheduledAt = tz.TZDateTime.from(targetTime, tz.local);

    debugPrint('[NotificationService] 현재 시각(local): $now');

    if (scheduledAt.isBefore(now)) {
      debugPrint('[NotificationService] 스킵 (이미 지남): $scheduledAt');
      return;
    }

    try {
      await _plugin.zonedSchedule(
        _notificationId(item.id),
        AppStrings.notif72hTitle,
        AppStrings.notif72hBody(item.name),
        scheduledAt,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: item.id,
      );
      debugPrint('[NotificationService] ✅ 예약 완료 → $scheduledAt');
    } catch (e) {
      debugPrint('[NotificationService] ❌ 예약 실패: $e');
    }
  }

  Future<void> cancelWishNotifications(String itemId) async {
    await _plugin.cancel(_notificationId(itemId));
    debugPrint('[NotificationService] 취소 완료: $itemId');
  }
}
