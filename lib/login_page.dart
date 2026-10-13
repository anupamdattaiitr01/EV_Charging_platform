import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_page_ev_charge/otp_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_page_ev_charge/home_page.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:multi_page_ev_charge/user_details_page.dart';

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
  Future<void> _signInWithGoogle() async {
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
          MaterialPageRoute(builder: (context) => const UserDetailsPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page(title: "Select your EV")),
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
        title: const Text('Sign-In with Google Failed'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(
                        "Sign In To Continue Charging Your EV Vehicle",
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
                            return 'Please enter your phone number';
                          }
                          String cleanNumber = phone.number.replaceAll(' ', '');
                          if (cleanNumber.length != 10) {
                            return 'Please enter exactly 10 digits';
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF161B22),
                          hintText: 'Enter your Phone Number',
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
                                    SnackBar(content: Text("Storage Error: $e")),
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
                            "Send OTP!",
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
                        children: const [
                          Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("OR", style: TextStyle(color: Colors.white54)),
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
                          label: const Text(
                            "Continue with Google",
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
                          onPressed:  _signInWithGoogle,
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