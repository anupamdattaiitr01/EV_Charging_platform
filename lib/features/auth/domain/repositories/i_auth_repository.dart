import '../entities/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthUser?> checkAuthStatus();
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent, Function(String) onError);
  Future<AuthUser> verifyOTP(String verificationId, String smsCode);
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser> saveUserProfile(Map<String, dynamic> userData, String selectedRole);
  Future<void> signOut();
}