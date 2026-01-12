import 'package:shared/models/user.dart';

abstract class AuthService {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Stream<User?> get currentUser; // Stream to listen to auth state changes
  
  bool get isFirstRun;
  Future<void> completeOnboarding();
}
