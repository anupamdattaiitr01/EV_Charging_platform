import 'package:flutter/material.dart';
import 'package:multi_page_ev_charge/home_page.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'user_details_page.dart';

class otp_page extends StatefulWidget {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page(title: "Select your EV")),
        );
      } else {
        // New User: No data exists, route to form
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
          duration: const Duration(seconds: 4), // Keeps it on screen long enough to read
        ),
      );
    }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 48,
        height: 60,
        textStyle: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22), // Your dark grey box color
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
            SafeArea(child: Padding(
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
                        children: [Pinput(
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
                          // onPressed: () {
                          //   bool pos1 = true;
                          //   for (int i=0;i<enteredOtp.length;i++)
                          //     {
                          //       int code = enteredOtp.codeUnitAt(i);
                          //       // print (code);
                          //       if (code <48 || code > 57)
                          //         {
                          //           pos1 = false;
                          //           break;
                          //         }
                          //     }
                          //   // print (pos1);
                          //   if (enteredOtp.length ==6 && pos1)
                          //     {
                          //       print ('The OTP You entered is $enteredOtp');
                          //       Navigator.pushReplacement(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => home_page(title: "Select your EV"),
                          //         ),
                          //       );
                          //     }
                          //   else
                          //     {
                          //       print('The wrong OTP you entered is $enteredOtp');
                          //       print ("The OTP entered is not Valid!");
                          //     }
                          // },
                          // onPressed: () {
                          //   if (_formKey.currentState!.validate()) {
                          //
                          //     print('The OTP You entered is Correct');
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => home_page(title: "Select your EV"),
                          //       ),
                          //     );
                          //
                          //   } else {
                          //     print("The OTP entered is not Valid!");
                          //   }
                          // },
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              _verifyOtp();
                            }
                          },
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            "Verify & Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB), // Brand Blue
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // child: Text(
                          //   "Verify & Continue",
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.white,
                          //   ),
                          // ),
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

