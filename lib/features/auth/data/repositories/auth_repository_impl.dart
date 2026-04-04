import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Stream<UserModel?> get authStateChanges {
    return _datasource.authStateChanges.map(_mapFirebaseUser);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _datasource.signInWithEmail(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _datasource.signUpWithEmail(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  UserModel? get currentUser => _mapFirebaseUser(_datasource.currentUser);

  UserModel? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}
