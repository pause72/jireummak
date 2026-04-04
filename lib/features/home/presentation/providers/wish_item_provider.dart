import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/data/repositories/wish_item_repository_impl.dart';
import '../../../home/domain/models/wish_item_model.dart';
import '../../../home/domain/models/wish_item_status.dart';
import '../../../home/domain/models/wish_stats.dart';

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
    return AsyncValue.data(repository.items);
  }

  Future<void> addItem({
    required String name,
    double? price,
    String? category,
    String? reason,
  }) async {
    final item = WishItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      category: category,
      reason: reason,
      createdAt: DateTime.now(),
    );
    await ref.read(wishItemRepositoryProvider).addItem(item);
  }

  Future<void> deleteItem(String id) async {
    await ref.read(wishItemRepositoryProvider).deleteItem(id);
  }

  Future<void> updateStatus(String id, WishItemStatus status) async {
    await ref.read(wishItemRepositoryProvider).updateStatus(id, status);
  }
}

@riverpod
List<WishItem> waitingItems(Ref ref) {
  return ref
          .watch(wishItemNotifierProvider)
          .valueOrNull
          ?.where((i) => i.status == WishItemStatus.waiting)
          .toList() ??
      [];
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
