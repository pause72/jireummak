import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/data/repositories/wish_item_repository_impl.dart';
import '../../../home/domain/models/wish_item_model.dart';
import '../../../home/domain/models/wish_item_status.dart';
import '../../../home/domain/models/wish_stats.dart';
import '../../../../core/services/notification_service.dart';
import '../../../my/presentation/providers/notification_settings_provider.dart';

part 'wish_item_provider.g.dart';

@riverpod
class WishItemNotifier extends _$WishItemNotifier {
  @override
  AsyncValue<List<WishItem>> build() {
    final repository = ref.watch(wishItemRepositoryProvider);
    final sub = repository.itemsStream.listen(
      (items) => state = AsyncValue.data(items),
      onError: (Object e, StackTrace st) => state = AsyncValue.error(e, st),
    );
    ref.onDispose(sub.cancel);
    // Firestore는 첫 이벤트가 비동기이므로 캐시된 items로 초기화
    return AsyncValue.data(repository.items);
  }

  Future<void> addItem({
    String? id,
    required String name,
    double? price,
    String? category,
    String? reason,
  }) async {
    final item = WishItem(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      category: category,
      reason: reason,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(wishItemRepositoryProvider).addItem(item);
      final notifEnabled = ref.read(notificationSettingsNotifierProvider);
      if (notifEnabled) {
        await NotificationService().scheduleWishNotifications(item);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateItem(String id, {required String name, double? price, String? reason}) async {
    try {
      await ref.read(wishItemRepositoryProvider).updateItem(id, name: name, price: price, reason: reason);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await ref.read(wishItemRepositoryProvider).deleteItem(id);
      await NotificationService().cancelWishNotifications(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String id, WishItemStatus status) async {
    try {
      await ref.read(wishItemRepositoryProvider).updateStatus(id, status);
      await NotificationService().cancelWishNotifications(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearError() {
    final cached = ref.read(wishItemRepositoryProvider).items;
    state = AsyncValue.data(cached);
  }
}

@riverpod
List<WishItem> waitingItems(Ref ref) {
  final items = ref
          .watch(wishItemNotifierProvider)
          .valueOrNull
          ?.where((i) => i.status == WishItemStatus.waiting)
          .toList() ??
      [];

  items.sort((a, b) {
    // 만료된 항목 우선
    if (a.isExpired != b.isExpired) return a.isExpired ? -1 : 1;
    // 남은 시간 적은 순
    return a.remainingDuration.compareTo(b.remainingDuration);
  });

  return items;
}

@riverpod
List<WishItem> allItems(Ref ref) {
  return ref.watch(wishItemNotifierProvider).valueOrNull ?? [];
}

@riverpod
WishStats wishStats(Ref ref) {
  return WishStats.fromItems(ref.watch(allItemsProvider));
}

@riverpod
Stream<DateTime> clockTick(Ref ref) {
  return Stream.periodic(
    const Duration(seconds: 30),
    (_) => DateTime.now(),
  );
}
