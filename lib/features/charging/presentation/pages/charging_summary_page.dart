import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/charging_session_entity.dart';
import '../bloc/charging_cubit.dart';

class ChargingSummaryPage extends StatelessWidget {
  const ChargingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    return BlocProvider.value(
      value: di.sl<ChargingCubit>(),
      child: BlocBuilder<ChargingCubit, ChargingState>(
        builder: (context, state) {
          final session = state.lastCompletedSession ??
              const ChargingSessionEntity(
                id: 'default',
                stationName: 'ChargeOn Highway Hub',
                gunTitle: 'Gun A',
                connectorType: 'CCS2',
                powerRating: '60kW',
                dateGroup: 'Today',
                timestampLabel: '17 Nov 2026 - 06:42 PM',
                timeOnlyLabel: '06:42 PM',
                energyKwh: 18.5,
                durationFormatted: '42 Min 18 Sec',
                durationShort: '42 Min',
                energyCost: 333.00,
                taxes: 59.94,
                platformFee: 10.00,
                totalPaid: 402.94,
                remainingWalletBalance: 847.06,
                status: 'Completed',
              );

          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                translator.translate("Session Summary"),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                            ),
                            child: const Icon(Icons.check, color: Color(0xFF00E676), size: 30),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          translator.translate("Charging Completed"),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildReceiptRow(
                                translator.translate("Charger:"),
                                translator.translate(session.stationName),
                                translator.translate("Date:"),
                                session.timestampLabel,
                              ),
                              const Divider(color: Colors.white10, height: 24),
                              _buildReceiptRowThree(
                                translator.translate("Energy Delivered:"),
                                '${session.energyKwh.toStringAsFixed(1)} KWh',
                                translator.translate("Duration:"),
                                session.durationFormatted,
                                translator.translate("Power Type:"),
                                '${session.connectorType} • ${session.powerRating}',
                              ),
                              const Divider(color: Colors.white10, height: 24),
                              _buildReceiptRowThree(
                                translator.translate("Energy Cost:"),
                                '₹ ${session.energyCost.toStringAsFixed(2)}',
                                translator.translate("Taxes:"),
                                '₹ ${session.taxes.toStringAsFixed(2)}',
                                translator.translate("Platform Fee:"),
                                '₹ ${session.platformFee.toStringAsFixed(2)}',
                              ),
                              const Divider(color: Colors.white10, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    translator.translate("Total Paid:"),
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    '₹ ${session.totalPaid.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardBgColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 24),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translator.translate("Paid Via Wallet"),
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${translator.translate("Wallet Balance Remaining:")} ₹ ${session.remainingWalletBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(translator.translate("Invoice downloaded"))),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              translator.translate("Download Invoice"),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: () {},
                          child: Text(
                            translator.translate("Share Receipt"),
                            style: const TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
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