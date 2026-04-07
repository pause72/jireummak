import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;

  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithNaver();
  Future<UserModel> signInWithKakao();
  Future<void> signOut();
}
