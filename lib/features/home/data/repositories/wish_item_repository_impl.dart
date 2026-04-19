import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/wish_item_model.dart';
import '../../domain/models/wish_item_status.dart';
import '../../domain/repositories/wish_item_repository.dart';

part 'wish_item_repository_impl.g.dart';

@riverpod
WishItemRepository wishItemRepository(Ref ref) {
  final authAsync = ref.watch(authStateProvider);
  final uid = authAsync.valueOrNull?.uid;

  if (uid == null) {
    return _EmptyWishItemRepository();
  }

  final repo = FirestoreWishItemRepository(uid: uid);
  ref.onDispose(repo.dispose);
  return repo;
}

// ─── Firestore 구현 ───────────────────────────────────────────────────────────

class FirestoreWishItemRepository implements WishItemRepository {
  FirestoreWishItemRepository({required this.uid});

  final String uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$uid/wishItems');

  List<WishItem> _cached = [];

  @override
  List<WishItem> get items => List.unmodifiable(_cached);

  @override
  Stream<List<WishItem>> get itemsStream => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(_fromDoc).toList();
        _cached = list;
        return list;
      });

  @override
  Future<void> addItem(WishItem item) async {
    await _col.doc(item.id).set(_toFirestore(item));
  }

  @override
  Future<void> updateItem(String id, {required String name, double? price, String? reason}) async {
    await _col.doc(id).update({'name': name, 'price': price, 'reason': reason});
  }

  @override
  Future<void> updateStatus(String id, WishItemStatus status) async {
    final now = DateTime.now();
    _cached = _cached
        .map((item) => item.id == id ? item.copyWith(status: status, decidedAt: now) : item)
        .toList();
    await _col.doc(id).update({
      'status': status.name,
      'decidedAt': Timestamp.fromDate(now),
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    _cached = _cached.where((item) => item.id != id).toList();
    await _col.doc(id).delete();
  }

  @override
  void dispose() {}

  // ── 변환 ──────────────────────────────────────────────────────────────────

  static WishItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final statusStr = data['status'] as String? ?? 'waiting';
    final status = WishItemStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => WishItemStatus.waiting,
    );
    final decidedAt = data['decidedAt'] != null
        ? (data['decidedAt'] as Timestamp).toDate()
        : null;
    return WishItem(
      id: doc.id,
      name: data['name'] as String,
      price: (data['price'] as num?)?.toDouble(),
      category: data['category'] as String?,
      reason: data['reason'] as String?,
      createdAt: createdAt,
      decidedAt: decidedAt,
      status: status,
    );
  }

  static Map<String, dynamic> _toFirestore(WishItem item) => {
        'name': item.name,
        'price': item.price,
        'category': item.category,
        'reason': item.reason,
        'createdAt': Timestamp.fromDate(item.createdAt),
        if (item.decidedAt != null) 'decidedAt': Timestamp.fromDate(item.decidedAt!),
        'status': item.status.name,
      };
}

// ─── 미로그인 상태용 빈 구현 ─────────────────────────────────────────────────

class _EmptyWishItemRepository implements WishItemRepository {
  @override
  List<WishItem> get items => const [];

  @override
  Stream<List<WishItem>> get itemsStream => const Stream.empty();

  @override
  Future<void> addItem(WishItem item) async {}

  @override
  Future<void> updateItem(String id, {required String name, double? price, String? reason}) async {}

  @override
  Future<void> updateStatus(String id, WishItemStatus status) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  void dispose() {}
}
