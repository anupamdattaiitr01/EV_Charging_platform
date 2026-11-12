import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Future<AuthUser?> checkAuthStatus() async {
    final User? currentUser = _firebaseAuth.currentUser;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? loginTimeString = prefs.getString('login_timestamp');

    if (currentUser != null && loginTimeString != null) {
      final DateTime loginTime = DateTime.parse(loginTimeString);
      if (DateTime.now().difference(loginTime).inDays < 3) {
        DataSnapshot snapshot = await _database.ref("users/${currentUser.uid}").get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>?;
          final String cleanRole = (data?['role']?.toString() ?? 'driver').replaceAll(RegExp(r'["\u0027]'), '').trim();
          return AuthUser(uid: currentUser.uid, role: cleanRole);
        }
      } else {
        await signOut();
      }
    }
    return null;
  }

  @override
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent, Function(String) onError) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) => onError(e.message ?? 'Verification Failed'),
      codeSent: (String verificationId, int? resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<AuthUser> verifyOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    UserCredential userCred = await _firebaseAuth.signInWithCredential(credential);

    if (userCred.user == null) throw Exception("Failed to retrieve user ID.");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_timestamp', DateTime.now().toIso8601String());

    DataSnapshot snapshot = await _database.ref("users/${userCred.user!.uid}").get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;
      final String cleanRole = (data?['role']?.toString() ?? 'driver').replaceAll(RegExp(r'["\u0027]'), '').trim();
      return AuthUser(uid: userCred.user!.uid, role: cleanRole);
    } else {
      return AuthUser(uid: userCred.user!.uid, isNewUser: true, newUserData: {'phone': userCred.user!.phoneNumber ?? ''});
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
    );

    UserCredential userCred = await _firebaseAuth.signInWithCredential(credential);
    if (userCred.user == null) throw Exception("Failed to retrieve user ID.");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_timestamp', DateTime.now().toIso8601String());

    DataSnapshot snapshot = await _database.ref("users/${userCred.user!.uid}").get();

    if (!snapshot.exists) {
      return AuthUser(uid: userCred.user!.uid, isNewUser: true, newUserData: {
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'profile_image_url': googleUser.photoUrl ?? '',
      });
    } else {
      final data = snapshot.value as Map<dynamic, dynamic>?;
      final String cleanRole = (data?['role']?.toString() ?? 'driver').replaceAll(RegExp(r'["\u0027]'), '').trim();
      return AuthUser(uid: userCred.user!.uid, role: cleanRole);
    }
  }

  @override
  Future<AuthUser> saveUserProfile(Map<String, dynamic> userData, String selectedRole) async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) throw Exception("No authenticated user found.");

    final String cleanRole = selectedRole.toLowerCase().trim();
    final Map<String, dynamic> finalData = Map<String, dynamic>.from(userData)
      ..['role'] = cleanRole
      ..['created_at'] = DateTime.now().toIso8601String();

    await _database.ref("users/${currentUser.uid}").set(finalData);
    return AuthUser(uid: currentUser.uid, role: cleanRole);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_timestamp');
  }
}