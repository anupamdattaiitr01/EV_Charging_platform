import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'features/auth/bloc/auth_cubit.dart';
import 'features/dashboard/bloc/dashboard_cubit.dart';
import 'features/profile/profile_page.dart';
import 'features/auth/getstarted_page.dart';
import 'features/dashboard/dash_board.dart';
import 'features/wallet/wallet_provider.dart';
import 'core/providers/locale_provider.dart';
import 'firebase_options.dart';

import 'features/manager/manager_dashboard.dart';

// --- 1. Top-Level Background Notification Handler ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

// --- 2. GoRouter Setup with AuthCubit Guard ---
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {

            // 1. Loading State
            if (authState is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              );
            }

            // 2. Success State (Logged in AND not a new user)
            // FIXED: Using AuthSuccess instead of AuthAuthenticated
            if (authState is AuthSuccess && !authState.isNewUser) {
              if (authState.role == 'manager') {
                return const ManagerDashboardPage();
              } else {
                return const DashboardPage();
              }
            }

            // 3. Unauthenticated / Initial State
            return const GetStartedPage();
          },
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important push notifications.',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
        BlocProvider(
          // FIXED: Appended ..checkAuthStatus() so it checks the session on startup!
          create: (_) => AuthCubit()..checkAuthStatus(),
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
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadPath = response.payload;
        if (payloadPath != null && payloadPath.trim().isNotEmpty) {
          final cleanPath = payloadPath.trim();
          final dashboardCubit = context.read<DashboardCubit>();

          if (cleanPath == '/profile') {
            _router.go('/');
            dashboardCubit.changeTab(5);
          } else if (cleanPath == '/wallet') {
            _router.go('/');
            dashboardCubit.changeTab(4);
          } else if (cleanPath == '/map') {
            _router.go('/');
            dashboardCubit.changeTab(1);
          } else if (cleanPath == '/history') {
            _router.go('/');
            dashboardCubit.changeTab(3);
          } else {
            _router.push(cleanPath);
          }
        }
      },
    );

    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _routeFromMessage(initialMessage);
        }
      });
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (mounted) {
        _routeFromMessage(message);
      }
    });
  }

  void _routeFromMessage(RemoteMessage message) {
    final String? deepLinkPath = message.data['deep_link'] ?? message.data['deep_link '];
    debugPrint("=== BACKGROUND/TERMINATED ROUTING TAPPED: $deepLinkPath ===");

    if (deepLinkPath != null && deepLinkPath.trim().isNotEmpty) {
      final cleanPath = deepLinkPath.trim();
      final dashboardCubit = context.read<DashboardCubit>();

      if (cleanPath == '/profile') {
        _router.go('/');
        dashboardCubit.changeTab(5);
      }
      else if (cleanPath == '/wallet') {
        _router.go('/');
        dashboardCubit.changeTab(4);
      }
      else if (cleanPath == '/map') {
        _router.go('/');
        dashboardCubit.changeTab(1);
      }
      else if (cleanPath == '/history') {
        _router.go('/');
        dashboardCubit.changeTab(3);
      }
      else {
        _router.push(cleanPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

// // =====================================================================
// // MANAGER DASHBOARD PAGE (Cascading Dropdowns)
// // =====================================================================
// class ManagerDashboardPage extends StatelessWidget {
//   const ManagerDashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // We wrap the view in a BlocProvider that automatically loads the JSON on startup
//     return BlocProvider(
//       create: (context) => ManagerFilterCubit()..loadFilters(),
//       child: const ManagerDashboardView(),
//     );
//   }
// }
//
// class ManagerDashboardView extends StatelessWidget {
//   const ManagerDashboardView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manager Analytics'),
//         backgroundColor: const Color(0xFF2563EB),
//         actions: [
//           // Moved the logout button to the top right!
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => context.read<AuthCubit>().signOut(),
//           )
//         ],
//       ),
//       // The BlocBuilder listens to our nested dropdown states
//       body: BlocBuilder<ManagerFilterCubit, ManagerFilterState>(
//         builder: (context, state) {
//           if (state.isLoading) {
//             return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
//           }
//
//           final cubit = context.read<ManagerFilterCubit>();
//
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Filter Station Data",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // ONE SINGLE MASTER DROPDOWN
//                 _buildDropdown<FlatFilterItem>(
//                   hint: "Select a Specific Charging Gun",
//                   value: state.selectedItem,
//                   items: state.allItems,
//                   getName: (FlatFilterItem item) => item.displayText,
//                   onChanged: (val) => cubit.selectItem(val),
//                 ),
//
//                 const Spacer(),
//
//                 // ACTION BUTTON
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: state.selectedItem == null
//                         ? null
//                         : () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Fetching analytics for ${state.selectedItem!.gun.title}..."),
//                           backgroundColor: const Color(0xFF2563EB),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF00E676),
//                       disabledBackgroundColor: const Color(0xFF161B22),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       "View Analytics",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: state.selectedItem == null ? Colors.white54 : Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // A reusable, styled widget for our dropdowns to keep the code clean
//   Widget _buildDropdown<T>({
//     required String hint,
//     required T? value,
//     required List<T> items,
//     required String Function(T) getName,
//     required void Function(T?)? onChanged,
//   }) {
//     final bool isDisabled = onChanged == null;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: isDisabled ? Colors.transparent : const Color(0xFF161B22),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDisabled ? Colors.white12 : Colors.white24,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           isExpanded: true,
//           hint: Text(hint, style: TextStyle(color: isDisabled ? Colors.white24 : Colors.white54)),
//           value: value,
//           dropdownColor: const Color(0xFF161B22),
//           icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.white24 : Colors.white54),
//           // Map our generic items into DropdownMenuItems
//           items: items.map((T item) {
//             return DropdownMenuItem<T>(
//               value: item,
//               child: Text(getName(item), style: const TextStyle(color: Colors.white)),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }