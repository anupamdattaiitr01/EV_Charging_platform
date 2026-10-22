import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // NEW
import 'package:go_router/go_router.dart'; // NEW
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/dashboard/bloc/dashboard_cubit.dart';
import 'features/profile/profile_page.dart';

import 'features/auth/getstarted_page.dart';
import 'features/dashboard/dash_board.dart';
import 'features/wallet/wallet_provider.dart';
import 'core/providers/locale_provider.dart';
import 'firebase_options.dart';

// --- 1. Top-Level Background Notification Handler ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

// --- 2. GoRouter Setup with Auth State Guard ---
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              );
            }
            if (snapshot.hasData) {
              return const DashboardPage();
            }
            return const GetStartedPage();
          },
        );
      },
    ),

    // UNCOMMENT THIS BLOCK
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),

    // GoRoute(
    //   path: '/wallet',
    //   builder: (context, state) => const WalletPage(),
    // ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // --- Register FCM background handler & request permissions ---
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("=== MY FCM TOKEN ===");
    debugPrint(fcmToken);
    debugPrint("====================");

  } catch (e) {
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DynamicTranslationProvider(),
        ),

        BlocProvider(
          create: (_) => DashboardCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// --- 3. Stateful MyApp for Notification Listeners ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationRouting();
  }

  Future<void> _setupNotificationRouting() async {
    // 1. App TERMINATED state: Launched by tapping notification
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _routeFromMessage(initialMessage);
    }

    // 2. App BACKGROUND state: Tapped from tray while backgrounded
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _routeFromMessage(message);
    });
  }

  void _routeFromMessage(RemoteMessage message) {
    final String? deepLinkPath = message.data['deep_link'];
    if (deepLinkPath != null && deepLinkPath.isNotEmpty) {
      _router.go(deepLinkPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. Use MaterialApp.router ---
    return MaterialApp.router(
      routerConfig: _router,
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
    );
  }
}