import 'package:flutter/material.dart';

class ChargingHistoryPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  const ChargingHistoryPage({super.key, required this.onBackToHome});

  @override
  State<ChargingHistoryPage> createState() => _ChargingHistoryPageState();
}

class _ChargingHistoryPageState extends State<ChargingHistoryPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserves scroll position & search text

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const cardBgColor = Color(0xFF161B22);

    return Stack(
      children: [
        // Background Glow
        Positioned(
          top: -120,
          left: -50,
          right: -50,
          child: Opacity(
            opacity: 0.6,
            child: Image.asset(
              'assets/images/Ellipse1.png',
              fit: BoxFit.cover,
              height: 400,
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: widget.onBackToHome, // Returns to Home tab
                    ),
                    const Text(
                      "Charging History",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Search Bar ---
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search By Station Name",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      suffixIcon: const Icon(Icons.search, color: Colors.white54, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Scrollable History List ---
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Text("Today", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildHistoryCard(cardBgColor),
                      const SizedBox(height: 12),
                      _buildHistoryCard(cardBgColor),
                      const SizedBox(height: 24),

                      const Text("Yesterday", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildHistoryCard(cardBgColor),
                      const SizedBox(height: 12),
                      _buildHistoryCard(cardBgColor),
                      const SizedBox(height: 24),

                      const Text("Feb 14, 2026", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildHistoryCard(cardBgColor),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Extracted Card Widget
  Widget _buildHistoryCard(Color cardBgColor) {
    const statusColor = Color(0xFF00E676); // Green

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2436), // Deep blue-gray
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "ChargeOn Highway Hub", //[cite: 1, 2]
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "18.5 KWh • 42 Min", //[cite: 1, 2]
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  "06:42 PM", //[cite: 1, 2]
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          // Price & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "₹402", //[cite: 1, 2]
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: const Text(
                  "Completed", //[cite: 1, 2]
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}