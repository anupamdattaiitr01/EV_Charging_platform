import 'package:flutter/material.dart';
import 'charging_summary_page.dart';

class ChargingProgressPage extends StatelessWidget {
  final VoidCallback onStopCharging;
  const ChargingProgressPage({super.key, required this.onStopCharging});

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFF161B22);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Charging In Progress",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "Choose An Available Connector",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.help_outline, color: Colors.white70),
          ),
        ],
      ),

      body: Stack(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: 0.68,
                          strokeWidth: 12,
                          backgroundColor: const Color(0xFF1B2735),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                        ),
                      ),

                      Container(
                        width: 175,
                        height: 175,
                        decoration: const BoxDecoration(
                          color: Color(0xFF111720),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "68%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Charging...",
                              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cardBgColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildMetricItem(icon: Icons.bolt, value: "58 KW", label: "Power"),
                      _buildDivider(),
                      _buildMetricItem(icon: Icons.battery_charging_full, value: "12.4 KWh", label: "Energy"),
                      _buildDivider(),
                      _buildMetricItem(icon: Icons.currency_rupee, value: "223.20", label: "Cost"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Time Elapsed:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            "00:18:24",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text("Estimated Full:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            "00:32:10 Remaining",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onStopCharging,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Stop Charging",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),]
      ),

      // --- 5. BOTTOM NAVIGATION BAR ---
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color(0xFF0D1117),
      //   currentIndex: 1, // Map tab active
      //   selectedItemColor: const Color(0xFF2563EB),
      //   unselectedItemColor: Colors.white38,
      //   type: BottomNavigationBarType.fixed,
      //   selectedFontSize: 11,
      //   unselectedFontSize: 11,
      //   onTap: (index) => Navigator.pop(context),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Map"),
      //     BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      //   ],
      // ),
    );
  }

  Widget _buildMetricItem({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.white12,
    );
  }
}