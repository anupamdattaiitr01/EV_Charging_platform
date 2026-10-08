import 'package:flutter/material.dart';
import 'charging_progress_page.dart';

class SelectGunPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onProceedToCharge;

  const SelectGunPage({
    super.key,
    required this.onBackToHome,
    required this.onProceedToCharge
  });

  @override
  State<SelectGunPage> createState() => _SelectGunPageState();
}

class _SelectGunPageState extends State<SelectGunPage> with AutomaticKeepAliveClientMixin {
  String selected_gun = '';
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    return Stack(
      children:  [
        Opacity(
          opacity: 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Image.asset(
              'assets/images/Ellipse1.png',
              width: 600,
              height: 600,
              fit: BoxFit.cover,
            ),
          ),
        ),

        SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBackToHome,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Select Charging Gun",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Choose An Available Connector",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "ChargeOn Highway Hub",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "2 Charging Points • 60kW",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 20),

              _buildGunCard(
                gunId: 'A',
                title: "Gun A",
                connector: "CCS2",
                speed: "60kW DC",
                statusText: "Available",
                statusColor: const Color(0xFF00E676),
                isAvailable: true,
                cardColor: cardBgColor,
              ),

              const SizedBox(height: 16),

              _buildGunCard(
                gunId: 'B',
                title: "Gun B",
                connector: "CCS2",
                speed: "60kW DC",
                statusText: "Available",
                statusColor: const Color(0xFF00E676),
                isAvailable: true,
                cardColor: cardBgColor,
              ),

              const SizedBox(height: 16),
              _buildGunCard(
                gunId: 'C',
                title: "Gun C",
                connector: "CCS2",
                speed: "60kW DC",
                statusText: "In Use",
                statusColor: const Color(0xFFFFA000),
                isAvailable: false,
                cardColor: cardBgColor,
              ),

              const SizedBox(height: 16),
              _buildGunCard(
                gunId: 'D',
                title: "Gun B",
                connector: "CCS2",
                speed: "60kW DC",
                statusText: "Available",
                statusColor: const Color(0xFF00E676),
                isAvailable: true,
                cardColor: cardBgColor,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(

                  onPressed: selected_gun.isNotEmpty ? widget.onProceedToCharge : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Proceed to Charge",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),]
    );
  }

  Widget _buildGunCard({
    required String gunId,
    required String title,
    required String connector,
    required String speed,
    required String statusText,
    required Color statusColor,
    required bool isAvailable,
    required Color cardColor,
  }) {
    final bool isSelected = selected_gun == gunId;

    return GestureDetector(
      onTap: isAvailable
          ? () {
        setState(() {
          selected_gun = gunId;
        });
      }
          : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.cable, color: Colors.white70, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(connector, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(speed, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 0.8),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}