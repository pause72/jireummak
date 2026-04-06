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
  Stream<UserModel?> get authStateChanges =>
      _datasource.authStateChanges.map(_mapFirebaseUser);

  @override
  UserModel? get currentUser => _mapFirebaseUser(_datasource.currentUser);

  @override
  Future<UserModel> signInWithGoogle() async {
    final credential = await _datasource.signInWithGoogle();
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<void> signOut() => _datasource.signOut();

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
