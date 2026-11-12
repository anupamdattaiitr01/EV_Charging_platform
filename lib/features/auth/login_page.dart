import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_cubit.dart';
import '../../core/providers/locale_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

typedef login_page = LoginPage;

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String numberEnt = "";
  String fullNumber = "";

  static const String _phoneKey = 'savedPhone';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(translator.translate('Authentication Failed')),
            description: Text(state.message),
            autoCloseDuration: const Duration(seconds: 4),
          );
        } else if (state is AuthCodeSent) {
          context.push('/otp', extra: state.verificationId);
        } else if (state is AuthSuccess) {
          if (state.isNewUser) {
            context.go('/user_details', extra: state.newUserData ?? {});
          } else {
            context.go('/');
          }
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          extendBodyBehindAppBar: true,
          // --- FIX 1: Prevent the keyboard from squishing the layout ---
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              Opacity(
                opacity: 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset('assets/images/Ellipse1.png', width: 600, height: 600, fit: BoxFit.cover),
                ),
              ),
              Center(
                child: SafeArea(
                  // --- FIX 2: Allow scrolling when keyboard covers the screen ---
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 80),
                            Text(
                              translator.translate("Welcome Back!"),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              translator.translate("Sign In To Continue Charging Your EV Vehicle"),
                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                            const SizedBox(height: 40),
                            IntlPhoneField(
                              controller: _phoneController,
                              validator: (phone) {
                                if (phone == null || phone.number.isEmpty) return translator.translate('Please enter your phone number');
                                if (phone.number.replaceAll(' ', '').length != 10) return translator.translate('Please enter exactly 10 digits');
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF161B22),
                                hintText: translator.translate('Enter your Phone Number'),
                                hintStyle: const TextStyle(color: Colors.white38),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                              style: const TextStyle(color: Colors.white),
                              dropdownTextStyle: const TextStyle(color: Colors.white),
                              initialCountryCode: 'IN',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (phone) {
                                numberEnt = phone.number;
                                fullNumber = phone.completeNumber;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final String cleanNumber = numberEnt.replaceAll(' ', '');
                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.setString(_phoneKey, cleanNumber);

                                    final String finalTargetPhone = fullNumber.isNotEmpty ? fullNumber : "+91$cleanNumber";
                                    if (context.mounted) context.read<AuthCubit>().sendOTP(finalTargetPhone);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : Text(translator.translate("Send OTP!"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(translator.translate("OR"), style: const TextStyle(color: Colors.white54)),
                                ),
                                const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
                                label: Text(translator.translate("Continue with Google"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithGoogle(),
                              ),
                            ),
                            // Add extra padding at the bottom so the user can scroll past the Google button
                            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 20 : 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}