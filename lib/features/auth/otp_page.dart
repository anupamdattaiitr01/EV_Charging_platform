import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // NEW: Imported GoRouter

import '../dashboard/home_page.dart';
import '../../core/providers/locale_provider.dart';
import 'user_details_page.dart';
import 'bloc/auth_cubit.dart';

// The Ui entry point
class OtpPage extends StatelessWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    // FIXED: Removed the duplicate BlocProvider creation.
    // Now it safely reads the global AuthCubit from main.dart!
    return _OtpView(verificationId: verificationId);
  }
}

typedef otp_page = OtpPage;

class _OtpView extends StatefulWidget {
  final String verificationId;
  const _OtpView({required this.verificationId});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String enteredOtp = "";

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 60,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.redAccent, width: 2),
    );

    return BlocConsumer<AuthCubit, AuthState>(
      // --- THE LISTENER: Handles Navigation and Errors ---
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${translator.translate('Error:')} ${state.message}"),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is AuthSuccess) {

            // 1. If it's a brand new user, let them complete onboarding
            if (state.isNewUser) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserDetailsPage()),
              );
            }
            // 2. FIXED: If existing user, route to '/' so main.dart checks the role!
            else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        },

        // --- THE BUILDER: Handles UI Painting ---
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;

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

                    SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                          child: Form(
                            key: _formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 100),
                                  Text(
                                    translator.translate("Verify Your Number"),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    translator.translate("Enter The 6-Digit OTP code"),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Pinput(
                                          length: 6,
                                          defaultPinTheme: defaultPinTheme,
                                          errorPinTheme: errorPinTheme,
                                          validator: (pin) {
                                            if (pin == null || !RegExp(r'^\d{6}$').hasMatch(pin)) {
                                              return translator.translate('Please enter all 6 digits');
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
                                        ),
                                      ]
                                  ),

                                  const SizedBox(height: 40),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthCubit>().verifyOTP(widget.verificationId, enteredOtp);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                      )
                                          : Text(
                                        translator.translate("Verify & Continue"),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: translator.translate("Didn't receive the code? "),
                                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: translator.translate("Resend OTP (30s)"),
                                            style: const TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const Spacer(),
                                ]
                            ),
                          ),
                        )
                    )
                  ]
              )
          );
        }
    );
  }
}