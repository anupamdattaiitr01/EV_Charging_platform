import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:multi_page_ev_charge/home_page.dart';
import 'package:multi_page_ev_charge/user_details_page.dart';


class otp_page extends StatefulWidget {
  // this is the additional verification code that is required to check the OTP entered
  // pass on from the log in page from the Firebase
  // Only the OTP code is useless, because multiple users may get the same OTP code
  // So we need an additional check that is passed on from the log in page
  // as soon as the code trigger to send OTP to user

  final String verificationId;
  const otp_page({super.key, required this.verificationId});
  @override
  State<otp_page> createState() => _otp_pageState();
}

class _otp_pageState extends State<otp_page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // bool pos = false;

  String enteredOtp = "";
  bool _isLoading = false;

  // The whole OTP validation part
  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    // this is the start of the verification process
    // trying to verify the OTP
    try
    {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
      );

      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCred.user!.uid;

      // Check if the user already has data in the Realtime Database
      // this is mandatory because we don't want the user to enter all the details again and again
      // everytime after the use log in
      DatabaseEvent event = await FirebaseDatabase.instance.ref("users/$uid").once();

      if (!mounted) return;

      if (event.snapshot.exists) {
        // If this is the first time user then we will move the user directly to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page(title: "Select your EV")),
        );
      } else {
        // New user now move the user to the user profile page to put in the required details

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDetailsPage()),
        );
      }
    }
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // this is the function that helps to first validate the OTP
  // and then authenticating with the firebase

  void _handleVerifySubmit() {
    if (_formKey.currentState!.validate()) {
      _verifyOtp();
    }
  }

  // returns the UI based on the condition
  Widget _buildButtonChild() {
    // already clicked the button and the firebase is checking in the background
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    // If not loading, show the normal text
    return const Text(
      "Verify & Continue",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 48,
        height: 60,
        textStyle: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
        ),
    );
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.redAccent, width: 2),
    );
    return
      Scaffold(
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

            SafeArea(child:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),

              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100),
                      Text(
                        "Verify Your Number",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Enter The 6-Digit OTP code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,

                          errorPinTheme: errorPinTheme,
                          validator: (pin) {
                            if (pin == null || !RegExp(r'^\d{6}$').hasMatch(pin)) {
                              return 'Please enter all 6 digits';
                            }

                            return null;
                          },

                          focusedPinTheme: defaultPinTheme.copyDecorationWith(
                            border: Border.all(color: const Color(0xFF2563EB), width: 2),
                          ),

                          autofocus: true,
                          keyboardType: TextInputType.number,


                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          onChanged: (pin) {
                            enteredOtp = pin;
                          },
                        ),]
                      ),

                      SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(

                          // Additional chek for the is_loading check
                          onPressed: _isLoading ? null : _handleVerifySubmit,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Calling the Custom Widget to get the hold of the cleaner UI,
                          // It returns the UI based on the condition'
                          child: _buildButtonChild(),

                        ),
                      ),

                      SizedBox(height: 24),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Didn't receive the code? ",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Resend OTP (30s)",
                                style: TextStyle(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      Spacer(),

                    ]
                ),
              ),
            )
            )
          ]
        )
      );
  }
}

