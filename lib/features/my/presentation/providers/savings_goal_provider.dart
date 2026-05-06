import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/savings_goal.dart';

part 'savings_goal_provider.g.dart';

@riverpod
class SavingsGoalNotifier extends _$SavingsGoalNotifier {
  static final _db = FirebaseFirestore.instance;

  @override
  List<SavingsGoal> build() {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    // Firestore 실시간 스트림 구독 (계정 전환 시 ref가 재빌드되어 자동 해제)
    final sub = _db
        .collection('users/${user.uid}/savingsGoals')
        .orderBy('createdAt')
        .snapshots()
        .listen((snap) {
      state = snap.docs.map(_fromDoc).toList();
    });
    ref.onDispose(sub.cancel);

    return [];
  }

  Future<void> add(SavingsGoal goal) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await _db.collection('users/$uid/savingsGoals').doc(goal.id).set({
      ..._toMap(goal),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(SavingsGoal goal) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    // createdAt은 덮어쓰지 않음
    await _db
        .collection('users/$uid/savingsGoals')
        .doc(goal.id)
        .update(_toMap(goal));
  }

  Future<void> delete(String id) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await _db.collection('users/$uid/savingsGoals').doc(id).delete();
  }

  // ── 변환 ────────────────────────────────────────────────────

  static SavingsGoal _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SavingsGoal(
      id: doc.id,
      title: data['title'] as String,
      targetAmount: (data['targetAmount'] as num).toInt(),
      currentAmount: (data['currentAmount'] as num?)?.toInt() ?? 0,
      emoji: data['emoji'] as String? ?? '🎯',
    );
  }

  static Map<String, dynamic> _toMap(SavingsGoal goal) => {
        'title': goal.title,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'emoji': goal.emoji,
      };
}
