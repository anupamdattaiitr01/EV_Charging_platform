import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/getstarted_page.dart';
import 'features/wallet/wallet_provider.dart';
import 'core/providers/locale_provider.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/dashboard/dash_board.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // debugPrint('STEP 1: Flutter initialized');

  try {
    // debugPrint('STEP 2: Loading .env');
    await dotenv.load(fileName: '.env');
    // debugPrint('STEP 3: .env loaded successfully');

    // debugPrint('STEP 4: Initializing Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // debugPrint('STEP 5: Firebase initialized successfully');
  } catch (e, stackTrace) {
    // debugPrint('STARTUP ERROR: $e');
    // debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }

  // debugPrint('STEP 6: Calling runApp');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DynamicTranslationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Charging Platform',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF161B22),
        ),
        fontFamily: 'Roboto',
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Show a loading indicator while Firebase checks local storage
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            );
          }

          // 2. If a user session exists, navigate directly to Dashboard/Home
          if (snapshot.hasData) {
            return const DashboardPage(); // Replace with your Dashboard/Home widget name
          }

          // 3. Otherwise, show the starting/login screen
          return const GetStartedPage();
        },
      ),
    );
  }
}