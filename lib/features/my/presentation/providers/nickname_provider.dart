import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

part 'nickname_provider.g.dart';

const _kNicknameKey = 'user_nickname';
const _kManuallySetKey = 'nickname_manually_set';

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
    this.isManuallySet = false,
    this.isLoading = false,
  });

  final String nickname;
  final bool isManuallySet;
  final bool isLoading;

  // 아직 수동으로 변경한 적 없으면 한 번 변경 가능
  bool get canChange => !isManuallySet;

  NicknameState copyWith({String? nickname, bool? isManuallySet, bool? isLoading}) {
    return NicknameState(
      nickname: nickname ?? this.nickname,
      isManuallySet: isManuallySet ?? this.isManuallySet,
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
    final isManuallySet = prefs?.getBool(_kManuallySetKey) ?? false;

    final localState = NicknameState(
      nickname: cachedNick,
      isManuallySet: isManuallySet,
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
        // Firestore에 데이터 없으면 랜덤 닉네임 생성 후 저장
        final nick = state.nickname.isNotEmpty ? state.nickname : _generate();
        await _db.doc('users/$uid').set({
          'nickname': nick,
          'nicknameManuallySet': false,
        }, SetOptions(merge: true));
        prefs?.setString(_kNicknameKey, nick);
        prefs?.setBool(_kManuallySetKey, false);
        state = NicknameState(nickname: nick, isManuallySet: false);
        return;
      }

      final data = doc.data()!;
      final nick = data['nickname'] as String? ?? '';
      final isManuallySet = data['nicknameManuallySet'] as bool? ?? false;

      if (nick.isNotEmpty) {
        prefs?.setString(_kNicknameKey, nick);
        prefs?.setBool(_kManuallySetKey, isManuallySet);
        state = NicknameState(nickname: nick, isManuallySet: isManuallySet);
      }
    } catch (_) {}
  }

  /// 사용자가 직접 닉네임을 입력해 변경 (단 한 번만 가능)
  /// 반환값: null = 성공, 에러 메시지 문자열 = 실패
  Future<String?> setNickname(String newNick) async {
    if (!state.canChange) return null;

    final trimmed = newNick.trim();
    if (trimmed.isEmpty) return null;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    state = state.copyWith(isLoading: true);

    try {
      final nicknameRef = _db.doc('nicknames/$trimmed');
      final userRef = _db.doc('users/${user.uid}');

      await _db.runTransaction((txn) async {
        final nicknameSnap = await txn.get(nicknameRef);
        if (nicknameSnap.exists) {
          throw _DuplicateNicknameException();
        }
        // 닉네임 인덱스 등록
        txn.set(nicknameRef, {'uid': user.uid});
        // 유저 문서 업데이트
        txn.set(userRef, {
          'nickname': trimmed,
          'nicknameManuallySet': true,
        }, SetOptions(merge: true));
      });

      final prefs = ref.read(sharedPreferencesProvider).valueOrNull;
      prefs?.setString(_kNicknameKey, trimmed);
      prefs?.setBool(_kManuallySetKey, true);

      state = NicknameState(nickname: trimmed, isManuallySet: true);
      return null;
    } on _DuplicateNicknameException {
      state = state.copyWith(isLoading: false);
      return '이미 사용 중인 닉네임이에요.';
    } catch (_) {
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
