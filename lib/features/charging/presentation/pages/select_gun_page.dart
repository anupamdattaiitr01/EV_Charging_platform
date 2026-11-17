import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/locale_provider.dart';
import '../../../reviews/add_review_page.dart';
import '../../../reviews/review_media_players.dart';
import '../../domain/entities/charging_session_entity.dart';
import '../bloc/charging_cubit.dart';

class SelectGunPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onProceedToCharge;

  const SelectGunPage({
    super.key,
    required this.onBackToHome,
    required this.onProceedToCharge,
  });

  @override
  State<SelectGunPage> createState() => _SelectGunPageState();
}

class _SelectGunPageState extends State<SelectGunPage> with AutomaticKeepAliveClientMixin {
  late final ChargingCubit _chargingCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chargingCubit = di.sl<ChargingCubit>()..loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final translator = Provider.of<DynamicTranslationProvider>(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    return BlocProvider.value(
      value: _chargingCubit,
      child: BlocBuilder<ChargingCubit, ChargingState>(
        builder: (context, state) {
          return Stack(
            children: [
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
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  translator.translate("Choose An Available Connector"),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                                  translator.translate(state.stationName),
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  translator.translate(state.stationSubtitle),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddReviewPage(
                                      stationId: state.stationId,
                                      stationName: state.stationName,
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

                        if (state.isLoading && state.guns.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: brandBlue),
                            ),
                          )
                        else
                          ...state.guns.map((gun) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildGunCard(
                                gun: gun,
                                isSelected: state.selectedGun?.id == gun.id,
                                cardColor: cardBgColor,
                                translator: translator,
                                onTap: () => _chargingCubit.selectGun(gun),
                              ),
                            );
                          }),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.selectedGun != null ? widget.onProceedToCharge : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              translator.translate("Proceed to Charge"),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          translator.translate("Community Reviews"),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        StreamBuilder<List<StationReviewEntity>>(
                          stream: _chargingCubit.watchReviews(state.stationId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(color: brandBlue),
                                ),
                              );
                            }

                            final reviews = snapshot.data ?? [];
                            if (reviews.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  translator.translate("No reviews yet. Be the first!"),
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              );
                            }

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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGunCard({
    required ChargingGunEntity gun,
    required bool isSelected,
    required Color cardColor,
    required DynamicTranslationProvider translator,
    required VoidCallback onTap,
  }) {
    final statusColor = gun.isAvailable ? const Color(0xFF00E676) : const Color(0xFFFFA000);

    return GestureDetector(
      onTap: gun.isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.5),
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
                    translator.translate(gun.title),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(translator.translate(gun.connector), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(translator.translate(gun.speed), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 0.8),
              ),
              child: Text(
                translator.translate(gun.statusText),
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildReviewCard(
    StationReviewEntity review,
    DynamicTranslationProvider translator,
    Color cardColor,
    ) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardColor.withValues(alpha: 0.5),
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
        if (review.text.isNotEmpty)
          Text(review.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        if (review.text.isNotEmpty && (review.videoUrl.isNotEmpty || review.audioUrl.isNotEmpty))
          const SizedBox(height: 16),
        if (review.videoUrl.isNotEmpty)
          VideoReviewPlayer(videoUrl: review.videoUrl),
        if (review.videoUrl.isNotEmpty && review.audioUrl.isNotEmpty)
          const SizedBox(height: 12),
        if (review.audioUrl.isNotEmpty)
          AudioReviewPlayer(audioUrl: review.audioUrl),
      ],
    ),
  );
}