import 'package:flutter/material.dart';
import 'charging_progress_page.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'add_review_page.dart';
import 'review_media_players.dart';

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
    final translator = Provider.of<DynamicTranslationProvider>(context);
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
        child: SingleChildScrollView(
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
                      children: [
                        Text(
                          translator.translate("Select Charging Gun"),
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          translator.translate("Choose An Available Connector"),
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translator.translate("ChargeOn Highway Hub"),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          translator.translate("2 Charging Points • 60kW"),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddReviewPage(
                              stationId: "chargeon_hub_1",
                              stationName: "ChargeOn Highway Hub",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review, color: Color(0xFF00E5FF), size: 18),
                      label: Text(
                        translator.translate("Add Review"),
                        style: const TextStyle(color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ],
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
                  translator: translator,
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
                  translator: translator,
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
                  translator: translator,
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
                  translator: translator,
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
                    child: Text(
                      translator.translate("Proceed to Charge"),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 32),
                Text(
                  translator.translate("Community Reviews"),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('station_reviews/chargeon_hub_1').onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          translator.translate("No reviews yet. Be the first!"),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    Map<dynamic, dynamic> reviewsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<dynamic> reviews = reviewsMap.values.toList();
                    reviews.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(reviews[index], translator, cardBgColor);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
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
    required DynamicTranslationProvider translator,
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
                    translator.translate(title),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(translator.translate(connector), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(translator.translate(speed), style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                translator.translate(statusText),
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildReviewCard(Map<dynamic, dynamic> review, DynamicTranslationProvider translator, Color cardColor) {
  String text = review['text'] ?? '';
  String videoUrl = review['videoUrl'] ?? '';
  String audioUrl = review['audioUrl'] ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              translator.translate("EV Driver"),
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (text.isNotEmpty)
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),

        if (text.isNotEmpty && (videoUrl.isNotEmpty || audioUrl.isNotEmpty))
          const SizedBox(height: 16),

        if (videoUrl.isNotEmpty)
          VideoReviewPlayer(videoUrl: videoUrl),

        if (videoUrl.isNotEmpty && audioUrl.isNotEmpty)
          const SizedBox(height: 12),

        if (audioUrl.isNotEmpty)
          AudioReviewPlayer(audioUrl: audioUrl),
      ],
    ),
  );
}