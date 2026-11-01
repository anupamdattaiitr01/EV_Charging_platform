import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/bloc/auth_cubit.dart';
import 'bloc/manager_filter_cubit.dart';
import 'models/manager_filter_models.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManagerFilterCubit()..loadFilters(),
      child: const ManagerDashboardView(),
    );
  }
}

class ManagerDashboardView extends StatelessWidget {
  const ManagerDashboardView({super.key});

  // --- NEW: Trigger the Modal Bottom Sheet Wizard ---
  void _showFilterWizard(BuildContext context, ManagerFilterState state, ManagerFilterCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _FilterWizardSheet(
        regions: state.allRegions,
        onComplete: (region, station, gun) {
          cubit.selectSelection(region, station, gun);
          Navigator.pop(bottomSheetContext); // Close sheet when done
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Consistent theme bg
      appBar: AppBar(
        title: const Text(
          'Manager Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Glass-translucent look
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await context.read<AuthCubit>().signOut();
              if (context.mounted) context.go('/');
            },
          )
        ],
      ),
      body: BlocBuilder<ManagerFilterCubit, ManagerFilterState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
          }

          final cubit = context.read<ManagerFilterCubit>();
          final bool isSelected = state.selectedGun != null;

          String selectionLabel = "Select Region ➔ Station ➔ Gun";
          if (isSelected) {
            selectionLabel = "${state.selectedRegion!.title} ➔ ${state.selectedStation!.title} ➔ ${state.selectedGun!.title}";
          }

          return Stack(
            children: [
              // --- 1. App Background Theme Glow Overlay (FULL SCREEN STRETCH) ---
              Positioned.fill(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/Ellipse1.png',
                    fit: BoxFit.cover, // Ensures it stretches to cover the whole background
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contextual Title matching Good Evening
                      const Text(
                        "Welcome Manager, Anupam",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Filter Station Data",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      // --- UPGRADED SELECTOR CARD (Syncs with Battery/Nearest Charger Theme) ---
                      InkWell(
                        onTap: () => _showFilterWizard(context, state, cubit),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.1) : const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.5) : Colors.white12,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.15), blurRadius: 10)]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Leading Icon Box with background highlight matching app design
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.white10,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isSelected ? Icons.check_circle_outline : Icons.filter_alt_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Text Details Hierarchy styling match
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSelected ? "Selected Filter" : "Station Hierarchy",
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectionLabel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Animated Dropdown Arrow consistent with sub-views
                              const Icon(Icons.keyboard_arrow_right, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ACTION BUTTON Theme Align
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: !isSelected
                              ? null
                              : () {
                            context.push(
                              '/analytics',
                              extra: state.selectedGun,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB), // Primary action blue
                            disabledBackgroundColor: const Color(0xFF161B22), // Matching Wallet action grey-blues
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "View Analytics",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: !isSelected ? Colors.white30 : Colors.white,
                            ),
                          ),
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
}

// ============================================================================
// NEW: THE BOTTOM SHEET WIZARD WIDGET
// ============================================================================
class _FilterWizardSheet extends StatefulWidget {
  final List<RegionModel> regions;
  final Function(RegionModel, StationModel, GunModel) onComplete;

  const _FilterWizardSheet({required this.regions, required this.onComplete});

  @override
  State<_FilterWizardSheet> createState() => _FilterWizardSheetState();
}

class _FilterWizardSheetState extends State<_FilterWizardSheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  RegionModel? _selectedRegion;
  StationModel? _selectedStation;

  void _nextStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prevStep() {
    setState(() => _currentStep -= 1);
    _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["Select Region", "Select Station", "Select Charger"];
    final height = MediaQuery.of(context).size.height * 0.6; // FIXED height bug

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117), // Deep Dark Tint match
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle & Header Consistent Style
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_currentStep > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _prevStep,
                  )
                else
                  const SizedBox(width: 48), // Spacing padding

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      titles[_currentStep],
                      key: ValueKey<int>(_currentStep),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Paging Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildRegionList(),
                if (_selectedRegion != null) _buildStationList(),
                if (_selectedStation != null) _buildGunList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LEVEL 1: REGIONS
  Widget _buildRegionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.regions.length,
      itemBuilder: (context, index) {
        final region = widget.regions[index];
        return _buildListItem(
          title: region.title,
          icon: Icons.map_outlined,
          iconColor: const Color(0xFF2563EB), // Primary blue consistent with app theme
          onTap: () {
            setState(() => _selectedRegion = region);
            _nextStep(1);
          },
        );
      },
    );
  }

  // LEVEL 2: STATIONS
  Widget _buildStationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedRegion!.stations.length,
      itemBuilder: (context, index) {
        final station = _selectedRegion!.stations[index];
        return _buildListItem(
          title: station.title,
          icon: Icons.ev_station_outlined,
          iconColor: const Color(0xFF00E676), // Accent Charging Dot Green
          onTap: () {
            setState(() => _selectedStation = station);
            _nextStep(2);
          },
        );
      },
    );
  }

  // LEVEL 3: GUNS
  Widget _buildGunList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedStation!.guns.length,
      itemBuilder: (context, index) {
        final gun = _selectedStation!.guns[index];
        return _buildListItem(
          title: gun.title,
          icon: Icons.bolt,
          iconColor: const Color(0xFFFFB300), // Alert/Energy yellow matching app theme
          isFinal: true,
          onTap: () {
            widget.onComplete(_selectedRegion!, _selectedStation!, gun);
          },
        );
      },
    );
  }

  // Common UI styling Match
  Widget _buildListItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isFinal = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // Standard card gray
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: isFinal
            ? const Icon(Icons.check_circle_outline, color: Color(0xFF00E676), size: 20)
            : const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
      ),
    );
  }
}