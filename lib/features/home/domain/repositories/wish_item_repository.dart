import '../models/wish_item_model.dart';
import '../models/wish_item_status.dart';

abstract class WishItemRepository {
  List<WishItem> get items;
  Stream<List<WishItem>> get itemsStream;

  Future<void> addItem(WishItem item);
  Future<void> updateItem(String id, {required String name, double? price, String? reason});
  Future<void> updateStatus(String id, WishItemStatus status);
  Future<void> updateReasons(String id, {required List<String> buyReasons, required List<String> resistReasons});
  Future<void> deleteItem(String id);
  void dispose();
}
