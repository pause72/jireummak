import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

part 'nickname_provider.g.dart';

const _kNicknameKey = 'user_nickname';
const _kLastChangedAtKey = 'nickname_last_changed_at'; // epoch millis

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
  });

  final String nickname;
  final DateTime? lastChangedAt;
  final bool isLoading;

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

  NicknameState copyWith({String? nickname, DateTime? lastChangedAt, bool? isLoading, bool clearLastChangedAt = false}) {
    return NicknameState(
      nickname: nickname ?? this.nickname,
      lastChangedAt: clearLastChangedAt ? null : (lastChangedAt ?? this.lastChangedAt),
      isLoading: isLoading ?? this.isLoading,
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

    // 로컬 캐시로 즉시 초기화
    final cachedNick = prefs?.getString(_kNicknameKey) ?? '';
    final lastChangedMillis = prefs?.getInt(_kLastChangedAtKey);
    final lastChangedAt = lastChangedMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastChangedMillis)
        : null;

    final localState = NicknameState(
      nickname: cachedNick,
      lastChangedAt: lastChangedAt,
    );

    // 로그인 상태면 Firestore에서 동기화
    if (user != null) {
      _syncFromFirestore(user.uid);
    }

    return localState;
  }

  Future<void> _syncFromFirestore(String uid) async {
    try {
      final doc = await _db.doc('users/$uid').get();
      final prefs = ref.read(sharedPreferencesProvider).valueOrNull;

      if (!doc.exists || doc.data() == null) {
        // 신규 유저: 랜덤 닉네임 생성 후 저장
        final nick = state.nickname.isNotEmpty ? state.nickname : _generate();
        await _db.doc('users/$uid').set({
          'nickname': nick,
          'nicknameLastChangedAt': null,
        }, SetOptions(merge: true));
        await prefs?.setString(_kNicknameKey, nick);
        await prefs?.remove(_kLastChangedAtKey);
        state = NicknameState(nickname: nick);
        return;
      }

      final data = doc.data()!;
      final nick = data['nickname'] as String? ?? '';
      final changedTs = data['nicknameLastChangedAt'];
      final lastChangedAt = changedTs is Timestamp ? changedTs.toDate() : null;

      if (nick.isNotEmpty) {
        await prefs?.setString(_kNicknameKey, nick);
        if (lastChangedAt != null) {
          await prefs?.setInt(_kLastChangedAtKey, lastChangedAt.millisecondsSinceEpoch);
        } else {
          await prefs?.remove(_kLastChangedAtKey);
        }
        state = NicknameState(nickname: nick, lastChangedAt: lastChangedAt);
      }
    } catch (e) {
      debugPrint('[NicknameNotifier] sync failed: $e');
    }
  }

  /// 닉네임 변경 (30일에 1회)
  /// 반환값: null = 성공, 에러 메시지 문자열 = 실패
  Future<String?> setNickname(String newNick) async {
    final trimmed = newNick.trim();
    if (trimmed.isEmpty) return '닉네임을 입력해주세요.';

    if (!state.canChange) {
      return '${state.daysUntilNextChange}일 후에 변경할 수 있어요.';
    }

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return '로그인이 필요해요.';

    if (trimmed == state.nickname) return '현재 닉네임과 같아요.';

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
      await prefs?.setString(_kNicknameKey, trimmed);
      await prefs?.setInt(_kLastChangedAtKey, now.millisecondsSinceEpoch);

      state = NicknameState(nickname: trimmed, lastChangedAt: now);
      return null;
    } on _DuplicateNicknameException {
      state = state.copyWith(isLoading: false);
      return '이미 사용 중인 닉네임이에요.';
    } on FirebaseException catch (e) {
      debugPrint('[NicknameNotifier] setNickname failed: $e');
      state = state.copyWith(isLoading: false);
      if (e.code == 'permission-denied') {
        return '변경 권한이 없어요. 다시 로그인 후 시도해 주세요.';
      }
      return '오류가 발생했어요. 다시 시도해 주세요.';
    } catch (e) {
      debugPrint('[NicknameNotifier] setNickname failed: $e');
      state = state.copyWith(isLoading: false);
      return '오류가 발생했어요. 다시 시도해 주세요.';
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
