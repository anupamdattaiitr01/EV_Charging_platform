import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_page_ev_charge/otp_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class login_page extends StatefulWidget {
  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {

  final TextEditingController _phoneController = TextEditingController();
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

                      keyboardType: TextInputType.phone,

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

                        onPressed: () async {
                          String cleanNumber = number_ent.replaceAll(' ', '');

                          if (cleanNumber.length == 10) {
                            try {
                              // Connection call
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              // Ensuring typesafety by using _phoneKey
                              await prefs.setString(_phoneKey, cleanNumber);

                              if (!context.mounted) return;


                              // this is the function that is triggered when user
                              // enters the phone number
                              // this function again call a fucntion ---- verify_number ();
                              await sendOTP(full_number.isNotEmpty ? full_number : "+91$cleanNumber");

                              // // 3. MANDATORY FLUTTER CHECK: Ensure the screen still exists after the await
                              // if (!context.mounted) return;

                              // // 4. Navigate to OTP Page
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => otp_page(),
                              //   ),
                              // );
                            }
                            catch (e) {
                              // If storage fails, show the error on screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Storage Error: $e")),
                              );
                            }
                          } else {
                            // Show the visual error

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid! Number length is ${cleanNumber.length}, needs to be 10."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
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
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}