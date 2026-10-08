import 'package:flutter/material.dart';
import 'dash_board.dart';

class ChargingSummaryPage extends StatelessWidget {
  const ChargingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Session Summary",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                // Checkmark circle
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF00E676), size: 30),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Charging Completed",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Itemized Receipt Box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow("Charger:", "ChargeOn Highway Hub", "Date:", "17 Feb 2026 - 06:42 PM"),
                      const Divider(color: Colors.white10, height: 24),
                      _buildReceiptRowThree("Energy Delivered:", "18.5 KWh", "Duration:", "42 Min 18 Sec", "Power Type:", "CCS2 • 60kW"),
                      const Divider(color: Colors.white10, height: 24),
                      _buildReceiptRowThree("Energy Cost:", "₹ 333.00", "Taxes:", "₹ 59.94", "Platform Fee:", "₹ 10.00"),
                      const Divider(color: Colors.white10, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Total Paid:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(
                            "₹ 402.94",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paid Via Wallet Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBgColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 24),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Paid Via Wallet",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Wallet Balance Remaining: ₹ 847.06",
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Download Invoice Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Download Invoice",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Share Receipt Text Button
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Share Receipt",
                    style: TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),]
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color(0xFF0D1117),
      //   currentIndex: 1, // Map tab active
      //   selectedItemColor: const Color(0xFF2563EB),
      //   unselectedItemColor: Colors.white38,
      //   type: BottomNavigationBarType.fixed,
      //   selectedFontSize: 11,
      //   unselectedFontSize: 11,
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

  static Widget _buildReceiptRow(String title1, String value1, String title2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value1, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title2, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  static Widget _buildReceiptRowThree(String t1, String v1, String t2, String v2, String t3, String v3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t1, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(v1, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(t2, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(v2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(t3, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(v3, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}