import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../map/map_page.dart';
import '../charging/select_gun_page.dart';
import '../charging/charging_progress_page.dart';
import '../charging/charging_summary_page.dart';
import '../charging/charging_history_page.dart';
import '../wallet/wallet_page.dart';
import '../profile/profile_page.dart';
import '../../core/providers/locale_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

// Import your new Cubit
import 'bloc/dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(),
      // 1. Changed this back to _DashboardView()
      child: const _DashboardView(),
    );
  }
}

// 2. Added the missing StatefulWidget class
class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {

  @override
  void initState() {
    super.initState();
    _setupForegroundNotifications();
  }

  void _setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Add this safety check before doing anything with the context!
      if (!mounted) return;

      if (message.notification != null) {
        final dashboardCubit = context.read<DashboardCubit>();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2563EB),
            content: Text(
              message.notification!.title ?? 'New Notification',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            action: SnackBarAction(
              textColor: Colors.white,
              label: 'View',
              onPressed: () {
                debugPrint("=== ALL RECEIVED DATA: ${message.data} ===");
                final String? deepLinkPath = message.data['deep_link'];
                debugPrint("=== SNACKBAR TAPPED: $deepLinkPath ===");

                if (deepLinkPath != null && deepLinkPath.isNotEmpty) {
                  final cleanPath = deepLinkPath.trim();

                  // Grab the global Cubit
                  final dashboardCubit = context.read<DashboardCubit>();
                  if (deepLinkPath == '/profile') {
                    dashboardCubit.changeTab(5);
                    _router.go('/');
                  } else if (deepLinkPath == '/wallet') {
                    dashboardCubit.changeTab(4);
                  } else if (deepLinkPath == '/map') {
                    dashboardCubit.changeTab(1);
                  } else if (deepLinkPath == '/history') {
                    dashboardCubit.changeTab(3);
                  } else {
                    context.push(deepLinkPath);
                  }
                }
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  // The Builders array is generated dynamically based on the current state
  List<Widget Function(BuildContext, DashboardState)> _getPageBuilders() => [
    // 0: Home
        (context, state) => _buildHomeView(context, state),

    // 1: Map Tab
        (context, state) => const MapPage(),

    // 2: Charge Tab (Handles the charging toggle)
        (context, state) => state.isCharging
        ? ChargingProgressPage(
      onStopCharging: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChargingSummaryPage()),
        ).then((_) {
          // Tell Cubit charging stopped, return to Home tab
          context.read<DashboardCubit>().setChargingStatus(false);
          context.read<DashboardCubit>().changeTab(0);
        });
      },
    )
        : SelectGunPage(
      onBackToHome: () => context.read<DashboardCubit>().changeTab(0),
      onProceedToCharge: () => context.read<DashboardCubit>().setChargingStatus(true),
    ),

    // 3: History Tab
        (context, state) => ChargingHistoryPage(
      onBackToHome: () => context.read<DashboardCubit>().changeTab(0),
    ),

    // 4: Wallet Tab
        (context, state) => WalletPage(
      onBackToHome: () => context.read<DashboardCubit>().changeTab(0),
    ),

    // 5: Profile Tab
        (context, state) => const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);

    // BlocBuilder listens to state changes and rebuilds the necessary widgets
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final builders = _getPageBuilders();

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xFF0D1117),
            currentIndex: state.selectedNavIndex,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            // Delegate tab switching to the Cubit
            onTap: (index) => context.read<DashboardCubit>().changeTab(index),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.bolt), label: translator.translate("Home")),
              BottomNavigationBarItem(icon: const Icon(Icons.location_on_outlined), label: translator.translate("Map")),
              BottomNavigationBarItem(icon: const Icon(Icons.ev_station), label: translator.translate("Charge")),
              BottomNavigationBarItem(icon: const Icon(Icons.history), label: translator.translate("History")),
              BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), label: translator.translate("Wallet")),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: translator.translate("Profile")),
            ],
          ),

          // IndexedStack preserves the state of tabs we have already visited
          body: IndexedStack(
            index: state.selectedNavIndex,
            children: List.generate(builders.length, (index) {
              if (state.loadedIndices.contains(index)) {
                return builders[index](context, state);
              }
              return const SizedBox.shrink();
            }),
          ),
        );
      },
    );
  }

  Widget _buildHomeView(BuildContext context, DashboardState state) {
    final translator = Provider.of<DynamicTranslationProvider>(context);

    return Stack(
      children: [
        Positioned(
          top: -120, left: -50, right: -50,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset('assets/images/Ellipse1.png', fit: BoxFit.cover, height: 400),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Vehicle & Weather)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translator.translate("Good Evening, Anupam"),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        // Data from Cubit
                        Text(
                          state.vehicleName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Data from Cubit
                            Text(
                                state.temperature,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                            ),
                            Text(
                                state.weatherCondition,
                                style: const TextStyle(color: Colors.white70, fontSize: 11)
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(state.weatherIcon, color: const Color(0xFFFFB300), size: 26),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Battery Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translator.translate("62%"),
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(translator.translate("Estimated Range"), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            translator.translate("212 Km Remaining"),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 72, height: 72,
                            child: CircularProgressIndicator(
                              value: 0.50,
                              strokeWidth: 7,
                              backgroundColor: Color(0xFF2D333B),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                            ),
                          ),
                          Text(
                            translator.translate("50%"),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wallet Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(translator.translate("Wallet Balance"), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("₹ 1,250.00", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF2563EB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Text(translator.translate("Recharge"), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nearest Charger Section
                Text(translator.translate("Nearest DC Fast Charger"), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            translator.translate("ChargeOn Highway Hub"),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translator.translate("Power:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 2),
                              const Text("60kW DC Fast", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(width: 48),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translator.translate("Distance:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(translator.translate("1.4 Km Away"), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translator.translate("Price:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 2),
                              const Text("₹18 / KWh", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton(
                            // Trigger the tab change directly through the Cubit
                            onPressed: () => context.read<DashboardCubit>().changeTab(2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(translator.translate("Start Charging"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Last Charging Session Section
                const Text("Last Charging Session", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                _buildSessionCard(
                  amount: "₹ 500", energy: "18.5 KWh", date: "20 Feb 2026", duration: "40 Min",
                  cardColor: const Color(0xFF161B22), translator: translator,
                ),
                const SizedBox(height: 12),
                _buildSessionCard(
                  amount: "₹ 333", energy: "18.5 KWh", date: "12 Feb 2026", duration: "42 Min",
                  cardColor: const Color(0xFF161B22), translator: translator,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Session Cards
  Widget _buildSessionCard({
    required String amount, required String energy, required String date,
    required String duration, required Color cardColor, required DynamicTranslationProvider translator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(Icons.access_time, color: Colors.white38, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(energy, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 14),
              const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 13),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 14),
              const Icon(Icons.schedule, color: Colors.white38, size: 13),
              const SizedBox(width: 4),
              Text("${translator.translate('Duration:')} $duration", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}






















// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '../map/map_page.dart';
// import '../charging/select_gun_page.dart';
// import '../charging/charging_progress_page.dart';
// import '../charging/charging_summary_page.dart';
// import '../charging/charging_history_page.dart';
// import '../wallet/wallet_page.dart';
// import '../profile/profile_page.dart';
// import 'package:provider/provider.dart';
// import '../../core/providers/locale_provider.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   // this vehicle name is updated from the Shared Preference
//   // Helps in the easier and faster loading of the details from the local memory
//   String vehicleName = "Loading Vehicle...";
//   int _selectedNavIndex = 0;
//   // Weather variables
//   String _temperature = "--°C";
//   String _weatherCondition = "Loading...";
//   IconData _weatherIcon = Icons.cloud_outlined;
//
//   final Set<int> _loadedIndices = {0};
//   bool _isCharging = false;
//
//   @override
//   void initState() {
//     print ('Init State of the Dashboard Page is called!');
//     super.initState();
//     _loadVehicleDetails();
//     _fetchWeather();
//   }
//
//
//
//   @override
//   // Shared Preference Variable details
//   // Getting the values to display on the dashbaord page
//   Future<void> _loadVehicleDetails() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String brand = prefs.getString('car_brand') ?? "Tata";
//     final String model = prefs.getString('car_model') ?? "Nexon EV";
//
//     setState(() {
//       vehicleName = "$brand $model";
//     });
//   }
//
//   Future<void> _fetchWeather() async {
//     final String weatherKey = dotenv.env['WEATHER_API_KEY'] ?? '';
//
//     // Check if the key is actually being read from the env file
//     if (weatherKey.isEmpty) {
//       print("Weather API Key is missing!!!");
//       return;
//     }
//
//     final url = Uri.parse(
//       'https://api.openweathermap.org/data/2.5/weather?lat=28.4354&lon=77.0823&appid=$weatherKey&units=metric',
//     );
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         print ("Details are fetched Successfully!");
//         final data = json.decode(response.body);
//
//         if (!mounted) return;
//         setState(() {
//           _temperature = "${data['main']['temp'].round()}°C";
//           _weatherCondition = data['weather'][0]['main'];
//
//           String conditionLower = _weatherCondition.toLowerCase();
//           if (conditionLower.contains('cloud')) {
//             _weatherIcon = Icons.cloud;
//           } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
//             _weatherIcon = Icons.water_drop;
//           } else if (conditionLower.contains('clear')) {
//             _weatherIcon = Icons.wb_sunny;
//           } else if (conditionLower.contains('thunder')) {
//             _weatherIcon = Icons.thunderstorm;
//           } else {
//             _weatherIcon = Icons.wb_cloudy;
//           }
//         });
//       }
//       else {
//         if (!mounted) return;
//         setState(() {
//           print ("Error in fetching the details from the weather API!");
//           _weatherCondition = "Error ${response.statusCode}";
//         });
//       }
//     }
//     catch (e) {
//       print("WEATHER EXCEPTION: $e");
//       if (!mounted) return;
//       setState(() {
//         _weatherCondition = "Offline";
//       });
//     }
//   }
//
//   List<Widget Function()> get _pageBuilders => [
//     // 0: Home
//         () => _buildHomeView(),
//
//         () => const MapPage(), // You will build this in map_page.dart
//
//     // 1: Map Tab (Handles the charging toggle)
//         () => _isCharging
//         ? ChargingProgressPage(
//       onStopCharging: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ChargingSummaryPage()),
//         ).then((_) {
//           setState(() {
//             _isCharging = false;
//             _selectedNavIndex = 0;
//           });
//         });
//       },
//     )
//         : SelectGunPage(
//       onBackToHome: () => setState(() => _selectedNavIndex = 0),
//       onProceedToCharge: () => setState(() => _isCharging = true),
//     ),
//
//     // 2: History Tab
//         () => ChargingHistoryPage(
//       onBackToHome: () => setState(() => _selectedNavIndex = 0),
//     ),
//
//     // 3: Wallet Tab
//         () => WalletPage(
//       onBackToHome: () => setState(() => _selectedNavIndex = 0),
//     ),
//
//     // 4: Profile Tab
//         () => const ProfilePage(),
//   ];
//
//     Widget _buildBody() {
//       final builders = _pageBuilders;
//
//       return IndexedStack(
//         index: _selectedNavIndex,
//         children: List.generate(builders.length, (index) {
//           // Only execute the function and build the widget if it has been visited
//           if (_loadedIndices.contains(index)) {
//             return builders[index]();
//           }
//           // Otherwise, return an empty, zero-cost placeholder
//           return const SizedBox.shrink();
//         }),
//       );
//     }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     print('Dashbaord Bulid is called!');
//     final translator = Provider.of<DynamicTranslationProvider>(context);
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color(0xFF0D1117),
//         currentIndex: _selectedNavIndex,
//         selectedItemColor: const Color(0xFF2563EB),
//         unselectedItemColor: Colors.white38,
//         type: BottomNavigationBarType.fixed,
//         selectedFontSize: 11,
//         unselectedFontSize: 11,
//
//         onTap: (index)
//         {
//           setState(() {
//             _selectedNavIndex = index; // Switches tab on tap
//             _loadedIndices.add(index); // Add this line!
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: const Icon(Icons.bolt), label: translator.translate("Home")),
//           BottomNavigationBarItem(icon: const Icon(Icons.location_on_outlined), label: translator.translate("Map")),
//           BottomNavigationBarItem(icon: const Icon(Icons.ev_station), label: translator.translate("Charge")),
//           BottomNavigationBarItem(icon: const Icon(Icons.history), label: translator.translate("History")),
//           BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), label: translator.translate("Wallet")),
//           BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: translator.translate("Profile")),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }
//
//   Widget _buildHomeView() {
//     final translator = Provider.of<DynamicTranslationProvider>(context);
//     return Stack(
//       children: [
//         Positioned(
//           top: -120,
//           left: -50,
//           right: -50,
//           child: Opacity(
//             opacity: 0.5,
//             child: Image.asset(
//               'assets/images/Ellipse1.png',
//               fit: BoxFit.cover,
//               height: 400,
//             ),
//           ),
//         ),
//
//         SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           translator.translate("Good Evening, Anupam"),
//                           style: TextStyle(color: Colors.white70, fontSize: 14),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           vehicleName,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // --- NEW: Weather Info & Profile Icon ---
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                                 _temperature,
//                                 style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
//                             ),
//                             Text(
//                                 _weatherCondition,
//                                 style: const TextStyle(color: Colors.white70, fontSize: 11)
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 8),
//                         Icon(_weatherIcon, color: const Color(0xFFFFB300), size: 26),
//                         const SizedBox(width: 12),
//                         IconButton(
//                           onPressed: () {},
//                           icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//
//
//
//                 // Battery Card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF161B22),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             translator.translate("62%"),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 6),
//                           Text(translator.translate("Estimated Range"), style: TextStyle(color: Colors.white54, fontSize: 12)),
//                           SizedBox(height: 2),
//                           Text(
//                             translator.translate("212 Km Remaining"),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 72,
//                             height: 72,
//                             child: CircularProgressIndicator(
//                               value: 0.50,
//                               strokeWidth: 7,
//                               backgroundColor: Color(0xFF2D333B),
//                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
//                             ),
//                           ),
//                           Text(
//                             translator.translate("50%"),
//                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Wallet Card
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF161B22),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 4,
//                         margin: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF2563EB),
//                           borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(4),
//                             bottomRight: Radius.circular(4),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(translator.translate("Wallet Balance"), style: TextStyle(color: Colors.white70, fontSize: 13)),
//                                 Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   "₹ 1,250.00",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 OutlinedButton(
//                                   onPressed: () {},
//                                   style: OutlinedButton.styleFrom(
//                                     side: const BorderSide(color: Color(0xFF2563EB)),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   ),
//                                   child: Text(translator.translate("Recharge"), style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Nearest Charger Section
//                 Text(translator.translate("Nearest DC Fast Charger"), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF161B22),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             translator.translate("ChargeOn Highway Hub"),
//                             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Container(
//                             width: 10,
//                             height: 10,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF00E676),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       Row(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(translator.translate("Power:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                               SizedBox(height: 2),
//                               Text("60kW DC Fast", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//                             ],
//                           ),
//                           const SizedBox(width: 48),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(translator.translate("Distance:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                               SizedBox(height: 2),
//                               Text(translator.translate("1.4 Km Away"), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 18),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(translator.translate("Price:"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
//                               const SizedBox(height: 2),
//                               const Text("₹18 / KWh", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), // <-- Restored original price text
//                             ],
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               // Switches tab to Map (Tab 1), which renders SelectGunPage
//                               setState(() {
//                                 _selectedNavIndex = 2;
//                                 _loadedIndices.add(2);
//                               });
//
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF2563EB),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                             ),
//                             child: Text(translator.translate("Start Charging"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Last Charging Session Section
//                 const Text(
//                   "Last Charging Session",
//                   style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSessionCard(
//                   amount: "₹ 500",
//                   energy: "18.5 KWh",
//                   date: "20 Feb 2026",
//                   duration: "40 Min",
//                   cardColor: const Color(0xFF161B22),
//                   translator: translator,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSessionCard(
//                   amount: "₹ 333",
//                   energy: "18.5 KWh",
//                   date: "12 Feb 2026",
//                   duration: "42 Min",
//                   cardColor: const Color(0xFF161B22),
//                   translator: translator,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Custoim Wodget for creating the past session Charges
// Widget _buildSessionCard({
//   required String amount,
//   required String energy,
//   required String date,
//   required String duration,
//   required Color cardColor,
//   required DynamicTranslationProvider translator,
// }) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//     decoration: BoxDecoration(
//       color: cardColor,
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               amount,
//               style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Icon(Icons.access_time, color: Colors.white38, size: 18),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             const Icon(Icons.bolt, color: Colors.white38, size: 14),
//             const SizedBox(width: 4),
//             Text(energy, style: const TextStyle(color: Colors.white54, fontSize: 11)),
//             const SizedBox(width: 14),
//             const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 13),
//             const SizedBox(width: 4),
//             Text(date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
//             const SizedBox(width: 14),
//             const Icon(Icons.schedule, color: Colors.white38, size: 13),
//             const SizedBox(width: 4),
//             Text("${translator.translate('Duration:')} $duration", style: const TextStyle(color: Colors.white54, fontSize: 11)),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
//
