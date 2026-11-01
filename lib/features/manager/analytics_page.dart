import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import 'bloc/analytics_cubit.dart';
import 'models/analytics_model.dart';
import 'models/manager_filter_models.dart';

class AnalyticsPage extends StatelessWidget {
  final GunModel selectedGun;

  const AnalyticsPage({super.key, required this.selectedGun});

  @override
  Widget build(BuildContext context) {
    // Provide the cubit to this specific page and instantly load the data
    return BlocProvider(
      create: (context) => AnalyticsCubit()..loadAnalytics(selectedGun.id),
      child: _AnalyticsView(selectedGun: selectedGun),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  final GunModel selectedGun;

  const _AnalyticsView({required this.selectedGun});

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  // Toggle state: 0 for Daily, 1 for Monthly
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          '${widget.selectedGun.title} Analytics',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Match main app theme
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- 1. App Background Theme Glow Overlay (FULL SCREEN STRETCH) ---
          Positioned.fill( // Changed from Positioned(top: -120...) to Positioned.fill
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/Ellipse1.png',
                fit: BoxFit.cover, // Ensures it stretches to cover the whole background
              ),
            ),
          ),

          // --- 2. Scrollable Content ---
          SafeArea(
            child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading || state is AnalyticsInitial) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
                }

                if (state is AnalyticsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  );
                }

                if (state is AnalyticsLoaded) {
                  final data = state.data;
                  final isDaily = _selectedTabIndex == 0;
                  final activeTrends = isDaily ? data.dailyTrends : data.monthlyTrends;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. THE DAILY/MONTHLY TOGGLE ---
                        _buildToggleSwitch(),
                        const SizedBox(height: 24),

                        // --- 2. SUMMARY CARDS ---
                        const Text("Performance Summary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Cars Charged",
                                value: "${data.summary.totalCarsToday}",
                                icon: Icons.electric_car,
                                iconColor: const Color(0xFF00E676),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Energy Used",
                                value: "${data.summary.totalKwToday} kW",
                                icon: Icons.bolt,
                                iconColor: const Color(0xFFFFB300),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Revenue",
                                value: "₹${data.summary.revenueToday}",
                                icon: Icons.currency_rupee,
                                iconColor: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Active Hours",
                                value: "${data.summary.hoursActiveToday}h",
                                icon: Icons.schedule,
                                iconColor: const Color(0xFF9C27B0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- 3. BAR CHART (ENERGY USAGE) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Energy Consumption (kW)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Icon(Icons.bar_chart, color: Colors.white54, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildBarChart(activeTrends),
                        const SizedBox(height: 32),

                        // --- 4. PIE CHART (REVENUE DISTRIBUTION) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Revenue Generation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Icon(Icons.pie_chart_outline, color: Colors.white54, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPieChart(activeTrends),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // UI WIDGET BUILDERS
  // =======================================================================

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text("Daily Trends", style: TextStyle(color: _selectedTabIndex == 0 ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text("Monthly Trends", style: TextStyle(color: _selectedTabIndex == 1 ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<TrendData> trends) {
    if (trends.isEmpty) return const SizedBox();

    // Find the max value to scale the graph dynamically
    double maxY = trends.map((e) => e.kwUsed).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2, // Add 20% headroom above highest bar
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${rod.toY.round()} kW",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(trends[value.toInt()].label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          barGroups: trends.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.kwUsed,
                  color: const Color(0xFFFFB300),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<TrendData> trends) {
    if (trends.isEmpty) return const SizedBox();

    // Use predefined colors for the pie slices
    final List<Color> sliceColors = [
      const Color(0xFF2563EB), const Color(0xFF00E676),
      const Color(0xFFFFB300), const Color(0xFF9C27B0),
      const Color(0xFFF44336), const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: trends.asMap().entries.map((entry) {
                  return PieChartSectionData(
                    color: sliceColors[entry.key % sliceColors.length],
                    value: entry.value.revenue,
                    title: "", // Hide title inside the pie chart to keep it clean
                    radius: 30,
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: trends.asMap().entries.map((entry) {
                // Show up to 7 legends so it doesn't overflow
                if (entry.key >= 7) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: sliceColors[entry.key % sliceColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.value.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}