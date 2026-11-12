import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Core Imports
import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';

// Feature Imports
import 'features/auth/bloc/auth_cubit.dart';
import 'features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'core/providers/locale_provider.dart';
import 'firebase_options.dart';

// --- NEW IMPORT: Wallet Cubit (Removed old WalletProvider) ---
import 'features/wallet/presentation/bloc/wallet_cubit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load Environment Variables
    await dotenv.load(fileName: '.env');

    // 2. Initialize Dependency Injection (GetIt)
    await di.init();

    // 3. Initialize Firebase & FCM
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important push notifications.',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("=== FCM TOKEN: $fcmToken ===");

  } catch (e) {
    debugPrint("Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DynamicTranslationProvider()),
        BlocProvider(create: (_) => di.sl<DashboardCubit>()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuthStatus()),
        // --- NEW BLOC PROVIDER: Wallet Cubit ---
        BlocProvider(create: (_) => di.sl<WalletCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

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
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadPath = response.payload;
        if (payloadPath != null && payloadPath.trim().isNotEmpty) {
          _handleDeepLink(payloadPath.trim());
        }
      },
    );

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && mounted) {
      Future.delayed(const Duration(milliseconds: 800), () => _routeFromMessage(initialMessage));
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (mounted) _routeFromMessage(message);
    });
  }

  void _routeFromMessage(RemoteMessage message) {
    final String? deepLinkPath = message.data['deep_link'] ?? message.data['deep_link '];
    if (deepLinkPath != null && deepLinkPath.trim().isNotEmpty) {
      _handleDeepLink(deepLinkPath.trim());
    }
  }

  void _handleDeepLink(String path) {
    final dashboardCubit = context.read<DashboardCubit>();
    if (path == '/profile') {
      AppRouter.router.go('/');
      dashboardCubit.changeTab(5);
    } else if (path == '/wallet') {
      AppRouter.router.go('/');
      dashboardCubit.changeTab(4);
    } else if (path == '/map') {
      AppRouter.router.go('/');
      dashboardCubit.changeTab(1);
    } else if (path == '/history') {
      AppRouter.router.go('/');
      dashboardCubit.changeTab(3);
    } else {
      AppRouter.router.push(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router, // Connected to the new AppRouter
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