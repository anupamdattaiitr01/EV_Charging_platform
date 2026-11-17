import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/charging_session_entity.dart';
import '../bloc/charging_cubit.dart';

class ChargingHistoryPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  const ChargingHistoryPage({super.key, required this.onBackToHome});

  @override
  State<ChargingHistoryPage> createState() => _ChargingHistoryPageState();
}

class _ChargingHistoryPageState extends State<ChargingHistoryPage> with AutomaticKeepAliveClientMixin {
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

    return BlocProvider.value(
      value: _chargingCubit,
      child: BlocBuilder<ChargingCubit, ChargingState>(
        builder: (context, state) {
          final grouped = <String, List<ChargingSessionEntity>>{};
          for (final session in state.filteredHistory) {
            grouped.putIfAbsent(session.dateGroup, () => []).add(session);
          }

          return Stack(
            children: [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: widget.onBackToHome,
                          ),
                          Text(
                            translator.translate("Charging History"),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 24),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: TextField(
                          onChanged: _chargingCubit.updateHistorySearch,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: translator.translate("Search By Station Name"),
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            suffixIcon: const Icon(Icons.search, color: Colors.white54, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: state.isLoading && state.allHistory.isEmpty
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                            : grouped.isEmpty
                            ? Center(
                          child: Text(
                            translator.translate("No charging sessions found."),
                            style: const TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        )
                            : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: grouped.entries.expand((entry) {
                            return [
                              Text(
                                translator.translate(entry.key),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...entry.value.map(
                                    (session) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildHistoryCard(session, cardBgColor, translator),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ];
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
      ChargingSessionEntity session,
      Color cardBgColor,
      DynamicTranslationProvider translator,
      ) {
    const statusColor = Color(0xFF00E676);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2436),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translator.translate(session.stationName),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.energyKwh.toStringAsFixed(1)} KWh • ${session.durationShort}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  session.timeOnlyLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${session.totalPaid.round()}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  translator.translate(session.status),
                  style: const TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}