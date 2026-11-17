import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/locale_provider.dart';
import '../bloc/charging_cubit.dart';

class ChargingProgressPage extends StatefulWidget {
  final VoidCallback onStopCharging;
  const ChargingProgressPage({super.key, required this.onStopCharging});

  @override
  State<ChargingProgressPage> createState() => _ChargingProgressPageState();
}

class _ChargingProgressPageState extends State<ChargingProgressPage> {
  late final ChargingCubit _chargingCubit;

  @override
  void initState() {
    super.initState();
    _chargingCubit = di.sl<ChargingCubit>();
    if (!_chargingCubit.state.isCharging) {
      _chargingCubit.startChargingSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);
    const cardBgColor = Color(0xFF161B22);

    return BlocProvider.value(
      value: _chargingCubit,
      child: BlocBuilder<ChargingCubit, ChargingState>(
        builder: (context, state) {
          final percentText = '${(state.progress * 100).round()}%';
          final gunSubtitle = state.selectedGun != null
              ? '${state.selectedGun!.title} • ${state.selectedGun!.connector} (${state.selectedGun!.speed})'
              : 'Gun A • CCS2 (60kW DC)';

          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translator.translate("Charging In Progress"),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    translator.translate(gunSubtitle),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                                  value: state.progress,
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
                                  children: [
                                    Text(
                                      percentText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      translator.translate("Charging..."),
                                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13),
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
                            color: cardBgColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _buildMetricItem(
                                icon: Icons.bolt,
                                value: '${state.currentPowerKw.toStringAsFixed(0)} KW',
                                label: translator.translate("Power"),
                              ),
                              _buildDivider(),
                              _buildMetricItem(
                                icon: Icons.battery_charging_full,
                                value: '${state.energyDeliveredKwh.toStringAsFixed(1)} KWh',
                                label: translator.translate("Energy"),
                              ),
                              _buildDivider(),
                              _buildMetricItem(
                                icon: Icons.currency_rupee,
                                value: state.currentCost.toStringAsFixed(2),
                                label: translator.translate("Cost"),
                              ),
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
                                children: [
                                  Text(
                                    translator.translate("Time Elapsed:"),
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.formattedElapsed,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    translator.translate("Estimated Full:"),
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${state.formattedRemaining} ${translator.translate("Remaining")}',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                            onPressed: () async {
                              await _chargingCubit.stopChargingSession();
                              widget.onStopCharging();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              translator.translate("Stop Charging"),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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