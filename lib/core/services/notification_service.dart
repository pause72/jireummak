// FCM 푸시 알림 서비스 — firebase_messaging 연동 시 활성화 예정
// ignore_for_file: unused_element

import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    debugPrint('[NotificationService] FCM 미연동 상태 — 추후 활성화');
  }
}
