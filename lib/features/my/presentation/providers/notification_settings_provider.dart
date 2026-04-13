import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/home/domain/models/wish_item_status.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

part 'notification_settings_provider.g.dart';

const _kNotifEnabledKey = 'notification_enabled';

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    return prefs?.getBool(_kNotifEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider).valueOrNull;
    await prefs?.setBool(_kNotifEnabledKey, enabled);
    state = enabled;

    // 대기 중인 항목들의 알림 일괄 처리
    final waitingItems = ref
            .read(wishItemNotifierProvider)
            .valueOrNull
            ?.where((i) => i.status == WishItemStatus.waiting)
            .toList() ??
        [];

    final svc = NotificationService();
    if (enabled) {
      for (final item in waitingItems) {
        await svc.scheduleWishNotifications(item);
      }
    } else {
      for (final item in waitingItems) {
        await svc.cancelWishNotifications(item.id);
      }
    }
  }
}
