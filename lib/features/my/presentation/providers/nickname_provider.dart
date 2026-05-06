import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

part 'nickname_provider.g.dart';

// UID 기반 키: 계정 전환 시 다른 계정 데이터가 오염되지 않도록
String _nicknameKey(String uid) => 'user_nickname_$uid';
String _lastChangedAtKey(String uid) => 'nickname_last_changed_at_$uid';

const _adjectives = [
  '빠른', '용감한', '행복한', '귀여운', '멋진', '신나는', '달리는', '뛰어난', '씩씩한',
  '활발한', '느긋한', '당찬', '설레는', '반짝이는', '따뜻한', '시원한', '재빠른', '영리한',
  '용맹한', '든든한', '날쌘', '차분한', '유쾌한', '상냥한', '강인한',
];

const _nouns = [
  '판다', '호랑이', '독수리', '고양이', '강아지', '코끼리', '기린', '곰', '여우', '토끼',
  '사자', '늑대', '하마', '펭귄', '돌고래', '치타', '수달', '미어캣', '알파카', '코알라',
  '너구리', '다람쥐', '오리', '햄스터', '거북이',
];

class NicknameState {
  const NicknameState({
    required this.nickname,
    this.lastChangedAt,
    this.isLoading = false,
    this.isInitialized = false,
  });

  final String nickname;
  final DateTime? lastChangedAt;
  final bool isLoading;
  /// Firestore 동기화 완료 여부 — false 동안엔 UI에서 로딩 표시
  final bool isInitialized;

  // 한 번도 변경 안 했거나 30일 이상 지났으면 변경 가능
  bool get canChange {
    if (lastChangedAt == null) return true;
    return DateTime.now().difference(lastChangedAt!) >= const Duration(days: 30);
  }

  // 다음 변경까지 남은 일수 (canChange == true 이면 0)
  int get daysUntilNextChange {
    if (canChange) return 0;
    final elapsed = DateTime.now().difference(lastChangedAt!);
    return 30 - elapsed.inDays;
  }

  NicknameState copyWith({String? nickname, DateTime? lastChangedAt, bool? isLoading, bool? isInitialized, bool clearLastChangedAt = false}) {
    return NicknameState(
      nickname: nickname ?? this.nickname,
      lastChangedAt: clearLastChangedAt ? null : (lastChangedAt ?? this.lastChangedAt),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

@riverpod
class NicknameNotifier extends _$NicknameNotifier {
  static final _db = FirebaseFirestore.instance;

  @override
  NicknameState build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    final user = ref.watch(authStateProvider).valueOrNull;

    // 로그인 안 된 상태면 빈 상태 반환 (다른 계정 캐시 노출 방지)
    if (user == null) return const NicknameState(nickname: '');

    // UID 기반 키로 해당 계정의 캐시만 읽음
    final uid = user.uid;
    final cachedNick = prefs?.getString(_nicknameKey(uid)) ?? '';
    final lastChangedMillis = prefs?.getInt(_lastChangedAtKey(uid));
    final lastChangedAt = lastChangedMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastChangedMillis)
        : null;

    final localState = NicknameState(
      nickname: cachedNick,
      lastChangedAt: lastChangedAt,
    );

    // Firestore에서 동기화 (항상 최신값이 최종)
    _syncFromFirestore(uid);

    return localState;
  }

  Future<void> _syncFromFirestore(String uid) async {
    try {
      final doc = await _db.doc('users/$uid').get();
      final prefs = ref.read(sharedPreferencesProvider).valueOrNull;

      // doc이 없거나 nickname 필드가 비어 있으면 신규 유저로 처리
      // (카카오 로그인 시 Cloud Function이 nickname 없이 doc을 먼저 생성하는 케이스 포함)
      final existingNick = doc.exists && doc.data() != null
          ? (doc.data()!['nickname'] as String? ?? '')
          : '';

      if (existingNick.isEmpty) {
        final nick = _generate();
        await _db.doc('users/$uid').set({
          'nickname': nick,
          'nicknameLastChangedAt': null,
        }, SetOptions(merge: true));
        await prefs?.setString(_nicknameKey(uid), nick);
        await prefs?.remove(_lastChangedAtKey(uid));
        state = NicknameState(nickname: nick, isInitialized: true);
        return;
      }

      final data = doc.data()!;
      final changedTs = data['nicknameLastChangedAt'];
      final lastChangedAt = changedTs is Timestamp ? changedTs.toDate() : null;

      await prefs?.setString(_nicknameKey(uid), existingNick);
      if (lastChangedAt != null) {
        await prefs?.setInt(_lastChangedAtKey(uid), lastChangedAt.millisecondsSinceEpoch);
      } else {
        await prefs?.remove(_lastChangedAtKey(uid));
      }
      state = NicknameState(nickname: existingNick, lastChangedAt: lastChangedAt, isInitialized: true);
    } catch (e) {
      debugPrint('[NicknameNotifier] sync failed: $e');
      state = state.copyWith(isInitialized: true);
    }
  }

  /// 닉네임 변경 (30일에 1회)
  /// 반환값: null = 성공, 에러 메시지 문자열 = 실패
  Future<String?> setNickname(String newNick) async {
    final trimmed = newNick.trim();
    if (trimmed.isEmpty) return AppStrings.nicknameRequired;

    if (!state.canChange) {
      return AppStrings.nicknameChangeDays(state.daysUntilNextChange);
    }

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return AppStrings.nicknameLoginRequired;

    if (trimmed == state.nickname) return AppStrings.nicknameSameAsCurrent;

    state = state.copyWith(isLoading: true);

    try {
      final oldNick = state.nickname;
      final oldNicknameRef = _db.doc('nicknames/$oldNick');
      final newNicknameRef = _db.doc('nicknames/$trimmed');
      final userRef = _db.doc('users/${user.uid}');

      await _db.runTransaction((txn) async {
        // 모든 읽기 먼저
        final oldNickSnap = await txn.get(oldNicknameRef);
        final newNickSnap = await txn.get(newNicknameRef);

        if (newNickSnap.exists) throw _DuplicateNicknameException();

        // 이전 닉네임 인덱스 삭제 (본인 소유인 경우만)
        if (oldNickSnap.exists && oldNickSnap.data()?['uid'] == user.uid) {
          txn.delete(oldNicknameRef);
        }

        // 새 닉네임 인덱스 등록
        txn.set(newNicknameRef, {'uid': user.uid});

        // 유저 문서 업데이트 (문서 없어도 merge로 생성)
        txn.set(userRef, {
          'nickname': trimmed,
          'nicknameLastChangedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      final now = DateTime.now();
      final prefs = ref.read(sharedPreferencesProvider).valueOrNull;
      await prefs?.setString(_nicknameKey(user.uid), trimmed);
      await prefs?.setInt(_lastChangedAtKey(user.uid), now.millisecondsSinceEpoch);

      state = NicknameState(nickname: trimmed, lastChangedAt: now, isInitialized: true);
      return null;
    } on _DuplicateNicknameException {
      state = state.copyWith(isLoading: false);
      return AppStrings.nicknameDuplicate;
    } on FirebaseException catch (e) {
      debugPrint('[NicknameNotifier] setNickname failed: $e');
      state = state.copyWith(isLoading: false);
      if (e.code == 'permission-denied') {
        return AppStrings.nicknamePermissionDenied;
      }
      return AppStrings.nicknameErrorRetry;
    } catch (e) {
      debugPrint('[NicknameNotifier] setNickname failed: $e');
      state = state.copyWith(isLoading: false);
      return AppStrings.nicknameErrorRetry;
    }
  }

  static String _generate() {
    final rng = Random();
    final adj = _adjectives[rng.nextInt(_adjectives.length)];
    final noun = _nouns[rng.nextInt(_nouns.length)];
    final num = rng.nextInt(9000) + 1000;
    return '$adj$noun#$num';
  }
}

class _DuplicateNicknameException implements Exception {}
