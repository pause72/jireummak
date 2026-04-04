import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<UserModel?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<UserModel?> build() => const AsyncValue.data(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
