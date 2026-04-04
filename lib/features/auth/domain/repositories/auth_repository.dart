import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  UserModel? get currentUser;
}
