import 'package:flutter/foundation.dart'; // NEW: Required for debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {
  final String verificationId;
  AuthCodeSent(this.verificationId);
}

class AuthSuccess extends AuthState {
  final bool isNewUser;
  final Map<String, dynamic>? newUserData;
  final String role;

  AuthSuccess({
    required this.isNewUser,
    this.newUserData,
    this.role = 'driver',
  });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // ------------------------------------------------------------------------
  // 1. STARTUP CHECK
  // ------------------------------------------------------------------------
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? loginTimeString = prefs.getString('login_timestamp');

      if (currentUser != null && loginTimeString != null) {
        final DateTime loginTime = DateTime.parse(loginTimeString);
        final DateTime now = DateTime.now();
        final Duration difference = now.difference(loginTime);

        if (difference.inDays < 3) {
          DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${currentUser.uid}");
          DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            final data = snapshot.value as Map<dynamic, dynamic>?;
            final String rawRole = data?['role']?.toString() ?? 'driver';

            // CLEAN THE STRING
            final String cleanRole = rawRole.replaceAll('"', '').replaceAll("'", '').trim();
            debugPrint("=== STARTUP ROLE FETCHED: $cleanRole ===");

            emit(AuthSuccess(isNewUser: false, role: cleanRole));
            return;
          }
        } else {
          await FirebaseAuth.instance.signOut();
          await prefs.remove('login_timestamp');
        }
      }
      emit(AuthInitial());
    } catch (e) {
      emit(AuthInitial());
    }
  }

  // ------------------------------------------------------------------------
  // 2. SEND OTP
  // ------------------------------------------------------------------------
  Future<void> sendOTP(String phoneNumber) async {
    emit(AuthLoading());

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError("Verification Failed: ${e.message}"));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthCodeSent(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
    catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ------------------------------------------------------------------------
  // 3. GOOGLE SIGN IN
  // ------------------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthInitial());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String? uid = userCredential.user?.uid;

      if (uid == null) {
        emit(AuthError("Failed to retrieve user ID from Firebase."));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());

      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");
      DataSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) {
        emit(AuthSuccess(
            isNewUser: true,
            newUserData: {
              'name': googleUser.displayName ?? '',
              'email': googleUser.email,
              'profile_image_url': googleUser.photoUrl ?? '',
            }
        ));
      } else {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        final String rawRole = data?['role']?.toString() ?? 'driver';

        // CLEAN THE STRING
        final String cleanRole = rawRole.replaceAll('"', '').replaceAll("'", '').trim();
        debugPrint("=== GOOGLE LOGIN ROLE FETCHED: $cleanRole ===");

        emit(AuthSuccess(isNewUser: false, role: cleanRole));
      }

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ------------------------------------------------------------------------
  // 4. VERIFY OTP
  // ------------------------------------------------------------------------
  Future<void> verifyOTP(String verificationId, String smsCode) async {
    emit(AuthLoading());

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      String? uid = userCred.user?.uid;

      if (uid == null) {
        emit(AuthError("Failed to retrieve user ID from Firebase."));
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());

      DatabaseEvent event = await FirebaseDatabase.instance.ref("users/$uid").once();

      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        final String rawRole = data?['role']?.toString() ?? 'driver';

        // CLEAN THE STRING
        final String cleanRole = rawRole.replaceAll('"', '').replaceAll("'", '').trim();
        debugPrint("=== OTP LOGIN ROLE FETCHED: $cleanRole ===");

        emit(AuthSuccess(isNewUser: false, role: cleanRole));
      } else {
        emit(AuthSuccess(
            isNewUser: true,
            newUserData: {
              'phone': userCred.user?.phoneNumber ?? '',
            }
        ));
      }
    } catch (e) {
      emit(AuthError("Invalid OTP or Verification Failed."));
    }
  }

  // ------------------------------------------------------------------------
  // 5. SIGN OUT
  // ------------------------------------------------------------------------
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_timestamp');
    emit(AuthInitial());
  }
}











// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// abstract class AuthState {}
//
// class AuthInitial extends AuthState {}
//
// class AuthLoading extends AuthState {}
//
// class AuthCodeSent extends AuthState {
//   final String verificationId;
//   AuthCodeSent(this.verificationId);
// }
//
// class AuthSuccess extends AuthState {
//   final bool isNewUser;
//   final Map<String, dynamic>? newUserData;
//   AuthSuccess({required this.isNewUser, this.newUserData});
// }
//
// class AuthError extends AuthState {
//   final String message;
//   AuthError(this.message);
// }
//
//
// // This class is the Single source of the Truth for all the authentication related details in the app
// // First -- OTP send
// // Second --- Sign in with Google
// // Third --- Validating the OTP with Fire base
// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());
//
//   Future<void> checkAuthStatus() async {
//     emit(AuthLoading());
//
//     try {
//       final User? currentUser = FirebaseAuth.instance.currentUser;
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? loginTimeString = prefs.getString('login_timestamp');
//
//       if (currentUser != null && loginTimeString != null) {
//         final DateTime loginTime = DateTime.parse(loginTimeString);
//         final DateTime now = DateTime.now();
//         final Duration difference = now.difference(loginTime);
//
//         // Check if the session is within 3 days (72 hours)
//         if (difference.inDays < 3) {
//           // Check if the user's data exists in Realtime Database
//           DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${currentUser.uid}");
//           DataSnapshot snapshot = await userRef.get();
//
//           if (snapshot.exists) {
//             emit(AuthSuccess(isNewUser: false));
//             return;
//           }
//         } else {
//           // Session expired (> 3 days) -> sign out user automatically
//           await FirebaseAuth.instance.signOut();
//           await prefs.remove('login_timestamp');
//         }
//       }
//
//       // If no valid user or session expired
//       emit(AuthInitial());
//     } catch (e) {
//       emit(AuthInitial());
//     }
//   }
//
//   // Fire base auth Code that helps to get the OTP from fire base and send it to the user
//   Future<void> sendOTP(String phoneNumber) async {
//     emit(AuthLoading()); // it tells the UI to show loader and disable buttons
//
//
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//
//         verificationCompleted: (PhoneAuthCredential credential) {},
//         verificationFailed: (FirebaseAuthException e) {
//           emit(AuthError("Verification Failed: ${e.message}"));
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           emit(AuthCodeSent(verificationId));
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {},
//       );
//     }
//     catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }
//
//
//   // Sign In with Google Feature
//   Future<void> signInWithGoogle() async {
//     emit(AuthLoading());
//     // Here are the two major tasks that are dependent on two external service providers
//     // Google helps to get the user details  -- > handles account selection, user authentication and provides token to the firebase to establish users's Identity
//     // Firebase accepts the Google credential, verifies it, and gives your app a Firebase user identity and authentication session.
//
//     try {
//       // this is the inbuilt google sign in object
//       // That object comes with the google_sign_in package
//       // this object is later required to initiate the Google Sign in Process
//       final GoogleSignIn googleSignIn = GoogleSignIn(
//         scopes: ['email', 'profile'],
//       );
//
//       // Clears the cached session so the account picker always displays
//       await googleSignIn.signOut();
//
//       // Starting point of the Google authentication and it triggers the whole pop up and do the log in
//       // this object only fetch the details of the user
//       // don't do the authentication part
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//       // The Object is initiated with the required scopes and then
//       // the above created object is used to call the Sign in Method
//
//       // Checking point if the process is done successfully
//       // does it contain the object of type GoogleSignInAccount
//       if (googleUser == null)
//       {
//         emit(AuthInitial()); // User cancelled the pop-up
//         return;
//       }
//
//       // this is the call to fetch the authentication details from Google
//       // Once the user selected the account and account details are stored
//       // then Google tries to get the authentication details to establish connection with the firebase
//       // It stores the idToken and the AccessToken
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       // creating the firebase authentication set up
//       // Setting up the tokens given by the Google auth to an object
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//
//       // Code to check if the user is already present or not
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//       String? uid = userCredential.user?.uid;
//
//       if (uid == null) {
//         emit(AuthError("Failed to retrieve user ID from Firebase."));
//         return;
//       }
//
//       // Session logic so that user don't have to log in again and again
//       // Stamp the exact time of successful Google Auth to local storage
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
//
//
//       // Check if user record already exists in Realtime Database
//       DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");
//       DataSnapshot snapshot = await userRef.get();
//
//       if (!snapshot.exists) {
//         // New user: Route to User Details Page
//         emit(AuthSuccess(
//             isNewUser: true,
//             newUserData: {
//               'name': googleUser.displayName ?? '',
//               'email': googleUser.email,
//               'profile_image_url': googleUser.photoUrl ?? '',
//             }
//         ));
//       } else {
//         // Existing user: Route to Home Page
//         emit(AuthSuccess(isNewUser: false));
//       }
//
//     }
//     catch (e)
//     {
//       // if (!mounted) return;
//       // // ScaffoldMessenger.of(context).showSnackBar(
//       // //   SnackBar(content: Text("Google Sign-In Error: $e")),
//       // // );
//       // toastification.show(
//       //   context: context,
//       //   type: ToastificationType.error,
//       //   style: ToastificationStyle.flat,
//       //   // --- TRANSLATED TOAST ---
//       //   title: Text(translator.translate('Sign-In with Google Failed')),
//       //   description: Text(e.toString()),
//       //   autoCloseDuration: const Duration(seconds: 4),
//       //   alignment: Alignment.topRight,
//       // );
//       emit(AuthError(e.toString()));
//     }
//   }
//
//   // OTP Validation
//   Future<void> verifyOTP(String verificationId, String smsCode) async {
//     emit(AuthLoading());
//
//     // the credential is made with two things ===> verification ID + OTP submitted by user
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );
//
//       UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
//       String? uid = userCred.user?.uid;
//
//
//       if (uid == null) {
//         emit(AuthError("Failed to retrieve user ID from Firebase."));
//         return;
//       }
//
//       // Storing the session in the shared preference,
//       // So the user don't have to log in again
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
//
//       // Check if the user already has data in the Realtime Database
//       // this is mandatory because we don't want the user to enter all the details again and again
//       // everytime after the use log in
//       DatabaseEvent event = await FirebaseDatabase.instance.ref("users/$uid").once();
//
//       // Auth is successful
//       if (event.snapshot.exists)
//       {
//         emit(AuthSuccess(isNewUser: false));
//       }
//       else
//       {
//         emit(AuthSuccess(
//             isNewUser: true,
//             newUserData: {
//               'phone': userCred.user?.phoneNumber ?? '',
//             }
//         ));
//       }
//     } catch (e) {
//       emit(AuthError("Invalid OTP or Verification Failed."));
//     }
//   }
//
// }
