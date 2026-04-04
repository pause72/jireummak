import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/wish_item_model.dart';
import '../../domain/models/wish_item_status.dart';
import '../../domain/repositories/wish_item_repository.dart';

part 'wish_item_repository_impl.g.dart';

@riverpod
WishItemRepository wishItemRepository(Ref ref) {
  final repo = WishItemRepositoryImpl();
  ref.onDispose(repo.dispose);
  return repo;
}

class WishItemRepositoryImpl implements WishItemRepository {
  final List<WishItem> _items = [];
  final _controller = StreamController<List<WishItem>>.broadcast();

  WishItemRepositoryImpl() {
    _seedSampleData();
  }

  void _seedSampleData() {
    final now = DateTime.now();
    _items.addAll([
      // 대기중 — 진행 중
      WishItem(
        id: '1',
        name: '에어팟 프로',
        price: 329000,
        category: '전자기기',
        reason: '운동할 때 쓰고 싶어서',
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      WishItem(
        id: '2',
        name: '닌텐도 스위치',
        price: 398000,
        category: '게임',
        reason: 'Zelda 하고 싶어서',
        createdAt: now.subtract(const Duration(hours: 48)),
      ),
      WishItem(
        id: '3',
        name: '다이슨 헤어드라이어',
        price: 529000,
        category: '가전',
        reason: '머리 빨리 말리고 싶어서',
        createdAt: now.subtract(const Duration(hours: 60)),
      ),
      // 대기중 — 72시간 초과 (결정!)
      WishItem(
        id: '4',
        name: '뉴발란스 993',
        price: 219000,
        category: '패션',
        createdAt: now.subtract(const Duration(hours: 80)),
      ),
      // 구매함
      WishItem(
        id: '5',
        name: '무인양품 노트',
        price: 8900,
        category: '문구',
        reason: '일기 쓰려고',
        createdAt: now.subtract(const Duration(days: 5)),
        status: WishItemStatus.purchased,
      ),
      WishItem(
        id: '6',
        name: '애플워치 SE',
        price: 329000,
        category: '전자기기',
        reason: '운동 기록 남기고 싶어서',
        createdAt: now.subtract(const Duration(days: 10)),
        status: WishItemStatus.purchased,
      ),
      WishItem(
        id: '7',
        name: '카카오 프렌즈 인형',
        price: 35000,
        category: '취미',
        createdAt: now.subtract(const Duration(days: 14)),
        status: WishItemStatus.purchased,
      ),
      // 취소함
      WishItem(
        id: '8',
        name: '아이패드 미니',
        price: 699000,
        category: '전자기기',
        reason: '그냥 갖고 싶어서',
        createdAt: now.subtract(const Duration(days: 7)),
        status: WishItemStatus.cancelled,
      ),
      WishItem(
        id: '9',
        name: '스타벅스 텀블러',
        price: 42000,
        category: '생활',
        reason: '예뻐서',
        createdAt: now.subtract(const Duration(days: 20)),
        status: WishItemStatus.cancelled,
      ),
      WishItem(
        id: '10',
        name: '레고 테크닉',
        price: 189000,
        category: '취미',
        reason: '조립하면 재미있을 것 같아서',
        createdAt: now.subtract(const Duration(days: 30)),
        status: WishItemStatus.cancelled,
      ),
    ]);
  }

  @override
  List<WishItem> get items => List.unmodifiable(_items);

  @override
  Stream<List<WishItem>> get itemsStream => _controller.stream;

  @override
  Future<void> addItem(WishItem item) async {
    _items.add(item);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> updateStatus(String id, WishItemStatus status) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(status: status);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  void dispose() {
    _controller.close();
  }
}
