import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_gun_page.dart';
import 'charging_progress_page.dart';
import 'charging_summary_page.dart';
import 'charging_history_page.dart';
import 'wallet_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String vehicleName = "Loading Vehicle...";
  int _selectedNavIndex = 0;
  late PageController _pageController;
  bool _isCharging = false;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
    _pageController = PageController(initialPage: _selectedNavIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String brand = prefs.getString('car_brand') ?? "Tata";
    final String model = prefs.getString('car_model') ?? "Nexon EV";

    final Set<String> allKeys = prefs.getKeys();
    print("=== SharedPreferences Storage ===");
    for (String key in allKeys) {
      // Retrieves the dynamic value for each specific key
      final value = prefs.get(key);
      print("$key : $value");
    }
    print("=================================");print("Currently stored keys: $allKeys");

    setState(() {
      vehicleName = "$brand $model";
    });
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildHomeView(),

        // Map Tab (Index 1): Switches between Select Gun and Charging Progress
        // Map Tab (Index 1): Switches between Select Gun and Charging Progress
        _isCharging
            ? ChargingProgressPage(
          onStopCharging: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChargingSummaryPage(),
              ),
            ).then((_) {
              setState(() {
                _isCharging = false;
                _selectedNavIndex = 0;
              });
              _pageController.jumpToPage(0);
            });
          },
        )
            : SelectGunPage(
          onBackToHome: () {
            setState(() {
              _selectedNavIndex = 0;
            });
            _pageController.jumpToPage(0);
          },
          onProceedToCharge: () {
            setState(() {
              _isCharging = true; // Switches Map tab to ChargingProgressPage
            });
          },
        ),

        ChargingHistoryPage(
          onBackToHome: () {
            setState(() {
              _selectedNavIndex = 0;
            });
            _pageController.jumpToPage(0);
          },
        ),

        WalletPage(
          onBackToHome: () {
            setState(() {
              _selectedNavIndex = 0;
            });
            _pageController.jumpToPage(0);
          },
        ),

        const ProfilePage(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1117),
        currentIndex: _selectedNavIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index; // Switches tab on tap
          });
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildHomeView() {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -50,
          right: -50,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/Ellipse1.png',
              fit: BoxFit.cover,
              height: 400,
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Good Evening, Mahendra",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicleName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
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
                        children: const [
                          Text(
                            "62%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text("Estimated Range", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          SizedBox(height: 2),
                          Text(
                            "212 Km Remaining",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: const [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: 0.50,
                              strokeWidth: 7,
                              backgroundColor: Color(0xFF2D333B),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                            ),
                          ),
                          Text(
                            "50%",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Wallet Balance", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "₹ 1,250.00",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF2563EB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text("Recharge", style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
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
                const Text(
                  "Nearest DC Fast Charger",
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
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
                          const Text(
                            "ChargeOn Highway Hub",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Power:", style: TextStyle(color: Colors.white38, fontSize: 11)),
                              SizedBox(height: 2),
                              Text("60kW DC Fast", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(width: 48),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Distance:", style: TextStyle(color: Colors.white38, fontSize: 11)),
                              SizedBox(height: 2),
                              Text("1.4 Km Away", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
                            children: const [
                              Text("Price:", style: TextStyle(color: Colors.white38, fontSize: 11)),
                              SizedBox(height: 2),
                              Text("₹18 / KWh", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Switches tab to Map (Tab 1), which renders SelectGunPage
                              setState(() {
                                _selectedNavIndex = 1;
                              });
                              _pageController.jumpToPage(1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text("Start Charging", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Last Charging Session Section
                const Text(
                  "Last Charging Session",
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildSessionCard(
                  amount: "₹ 500",
                  energy: "18.5 KWh",
                  date: "20 Feb 2026",
                  duration: "40 Min",
                  cardColor: const Color(0xFF161B22),
                ),
                const SizedBox(height: 12),
                _buildSessionCard(
                  amount: "₹ 333",
                  energy: "18.5 KWh",
                  date: "12 Feb 2026",
                  duration: "42 Min",
                  cardColor: const Color(0xFF161B22),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custoim Wodget for creating the past session Charges
Widget _buildSessionCard({
  required String amount,
  required String energy,
  required String date,
  required String duration,
  required Color cardColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              amount,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            Text("Duration: $duration", style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ],
    ),
  );
}


