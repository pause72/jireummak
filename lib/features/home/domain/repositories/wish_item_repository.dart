import '../models/wish_item_model.dart';
import '../models/wish_item_status.dart';

abstract class WishItemRepository {
  List<WishItem> get items;
  Stream<List<WishItem>> get itemsStream;

  Future<void> addItem(WishItem item);
  Future<void> updateStatus(String id, WishItemStatus status);
  Future<void> deleteItem(String id);
  void dispose();
}
