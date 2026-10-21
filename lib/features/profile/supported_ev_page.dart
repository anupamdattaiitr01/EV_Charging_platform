import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SupportedEVPage extends StatefulWidget {
  const SupportedEVPage({super.key});

  @override
  State<SupportedEVPage> createState() => _SupportedEVPageState();
}

class _SupportedEVPageState extends State<SupportedEVPage> {
  bool _isLoading = true;

  // The actual data
  final List<Map<String, String>> supportedCars = [
    {'brand': 'Tata', 'model': 'Nexon EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Tata', 'model': 'Punch EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Tata', 'model': 'Tiago EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Tata', 'model': 'Curvv EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Mahindra', 'model': 'BE 6', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Mahindra', 'model': 'XEV 9e', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Mahindra', 'model': 'XUV400', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'MG', 'model': 'Windsor EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'MG', 'model': 'ZS EV', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'MG', 'model': 'Comet EV', 'connector': 'Type 2 AC'},
    {'brand': 'Maruti Suzuki', 'model': 'e Vitara', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Hyundai', 'model': 'Creta Electric', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Hyundai', 'model': 'Ioniq 5', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Kia', 'model': 'EV6', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'BYD', 'model': 'Atto 3', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'BYD', 'model': 'Seal', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'BMW', 'model': 'i4', 'connector': 'CCS2 & Type 2 AC'},
    {'brand': 'Mercedes-Benz', 'model': 'EQE', 'connector': 'CCS2 & Type 2 AC'},
  ];

  @override
  void initState() {
    super.initState();
    // Simulate a network API call delay of 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Supported EV Models',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Switch between the Shimmer loading effect and the actual list
      body: _isLoading ? _buildShimmerEffect() : _buildActualList(),
    );
  }

  // --- 1. The Shimmer Skeleton View ---
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: 8, // Show 8 placeholder cards while loading
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          // Apply the Shimmer animation over the placeholder layout
          child: Shimmer.fromColors(
            baseColor: Colors.white10,
            highlightColor: Colors.white24,
            child: Row(
              children: [
                // Skeleton for the circular icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skeleton for the Title text
                      Container(
                        width: double.infinity,
                        height: 16.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      // Skeleton for the Subtitle text
                      Container(
                        width: 120.0,
                        height: 12.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Skeleton for the check icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 2. The Actual Loaded List View ---
  Widget _buildActualList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: supportedCars.length,
      itemBuilder: (context, index) {
        final car = supportedCars[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.electric_car,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car['brand']} ${car['model']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connector: ${car['connector']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00E676),
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}