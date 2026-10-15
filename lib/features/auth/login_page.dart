import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'otp_page.dart';
import '../dashboard/home_page.dart';
import 'user_details_page.dart';
import 'getstarted_page.dart';
import '../../core/providers/locale_provider.dart';

class login_page extends StatefulWidget {
  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {

  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String number_ent = "";
  String full_number = "";

  // This helps in the mistype of the same string again and again
  static const String _phoneKey = 'savedPhone';

  // Fire base auth Code that helps to get the OTP from fire base and send it to the user
  Future<void> sendOTP(String phoneNumber) async {

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) {

      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification Failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => otp_page(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }


  // complete function for the Google auth feature
  Future<void> _signInWithGoogle(DynamicTranslationProvider translator) async {
    // Here are the two major tasks that are dependent on two external service providers
    // Google helps to get the user details  -- > handles account selection, user authentication and provides token to the firebase to establish users's Identity
    // Firebase accepts the Google credential, verifies it, and gives your app a Firebase user identity and authentication session.

    try {
      // this is the inbuilt google sign in object
      // That object comes with the google_sign_in package
      // this object is later required to initiate the Google Sign in Process
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Clears the cached session so the account picker always displays
      await googleSignIn.signOut();

      // Starting point of the Google authentication and it triggers the whole pop up and do the log in
      // this object only fetch the details of the user
      // don't do the authentication part
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      // The Object is initiated with the required scopes and then
      // the above created object is used to call the Sign in Method

      // Checking point if the process is done successfully
      // does it contain the object of type GoogleSignInAccount
      if (googleUser == null) return;

      // this is the call to fetch the authentication details from Google
      // Once the user selected the account and account details are stored
      // then Google tries to get the authentication details to establish connection with the firebase
      // It stores the idToken and the AccessToken
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // creating the firebase authentication set up
      // Setting up the tokens given by the Google auth to an object
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );


      // Establishing Connection with the Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      // Code to check if the user is already present or not
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String? uid = userCredential.user?.uid;

      if (uid == null) return;

      // Check if user record already exists in Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");
      DataSnapshot snapshot = await userRef.get();

      if (!mounted) return;

      if (!snapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(
              existingData: {
                'name': googleUser.displayName ?? '',
                'email': googleUser.email,
                'profile_image_url': googleUser.photoUrl ?? '',
              },
              isEditing: false, // This tells the page it's a new registration, not a profile edit
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home_page(title: translator.translate("Select your EV"))),
        );
      }

    }
    catch (e)
    {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Google Sign-In Error: $e")),
      // );
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        // --- TRANSLATED TOAST ---
        title: Text(translator.translate('Sign-In with Google Failed')),
        description: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topRight,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumber();
  }

  Future<void> _loadSavedPhoneNumber() async {
    // This establishes connection with the hard disc
    // So this  function is called in the init even before loading the page
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhone = prefs.getString(_phoneKey);

    if (savedPhone != null)
    {
      setState(() {
        number_ent = savedPhone;
        _phoneController.text = savedPhone; // Visually fills the text box
      });
    }
  }
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.asset(
                'assets/images/Ellipse1.png',
                width: 600,
                height: 600,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 100),
                      Text(
                        translator.translate("Welcome Back!"),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(
                        translator.translate("Sign In To Continue Charging Your EV Vehicle"),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      SizedBox(height: 40),
                      IntlPhoneField(
                        controller: _phoneController,

                        // Validator function of the child class
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return translator.translate('Please enter your phone number');
                          }
                          String cleanNumber = phone.number.replaceAll(' ', '');
                          if (cleanNumber.length != 10) {
                            return translator.translate('Please enter exactly 10 digits');
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF161B22),
                          hintText: translator.translate('Enter your Phone Number'),
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        style: TextStyle(color: Colors.white),
                        dropdownTextStyle: TextStyle(color: Colors.white),
                        initialCountryCode: 'IN',

                        // Strictly restricts the phone numpad to open up not the keyboard
                        keyboardType: TextInputType.phone,

                        // Only numbers are allowed in the input
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],

                        onChanged: (phone) {
                          number_ent = phone.number;
                          full_number = phone.completeNumber;
                        },
                        onSubmitted: (phone) {
                        },
                      ),

                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(

                          //
                          onPressed: () async {
                              // trigger the validator function of all the child class in the form widget
                              if (_formKey.currentState!.validate()) {

                                try {
                                  String cleanNumber = number_ent.replaceAll(' ', '');
                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString(_phoneKey, cleanNumber);

                                  if (!context.mounted) return;

                                  await sendOTP(full_number.isNotEmpty ? full_number : "+91$cleanNumber");

                                }
                                catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${translator.translate('Storage Error:')} $e")),
                                  );
                                }

                                // Implementing the try catch block is better than using the if else statements
                              }
                          },
                          style: ElevatedButton.styleFrom(

                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            translator.translate("Send OTP!"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Expansion of the new sign in method using the Google OAuth
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            // --- TRANSLATED DIVIDER ---
                            child: Text(translator.translate("OR"), style: TextStyle(color: Colors.white54)),
                          ),
                          Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // The Sign in button that diverts the page from APP to Google sign in
                      // If sign in passed successfully then it will divert directly to the Home page
                      // If done successfully it will not go in the OTP page
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
                          label: Text(
                            // --- TRANSLATED BUTTON ---
                            translator.translate("Continue with Google"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Calling the function that take care of the sign in through the google auth
                          onPressed: () => _signInWithGoogle(translator),
                            // toastification.show(
                            //   context: context,
                            //   type: ToastificationType.error,
                            //   style: ToastificationStyle.flat,
                            //   title: const Text('Sign-in with Google initiated!'),
                            //   // description: Text(e.toString()),
                            //   autoCloseDuration: const Duration(seconds: 4),
                            //   alignment: Alignment.bottomLeft,
                            // );

                        ),
                      ),

                      const Spacer(),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}