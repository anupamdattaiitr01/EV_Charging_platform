import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  const WalletPage({super.key, required this.onBackToHome});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with AutomaticKeepAliveClientMixin {
  String _selectedAmount = '';
  final TextEditingController _customAmountController = TextEditingController();

  @override
  bool get wantKeepAlive => true; // Preserves form inputs and selections

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow[cite: 3]
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
            child: Column(
              children: [
                // --- Header ---[cite: 3]
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        onPressed: widget.onBackToHome,
                      ),
                      const Text(
                        "Wallet Recharge",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.history, color: Colors.white, size: 24),
                    ],
                  ),
                ),

                // --- Scrollable Content ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Wallet Balance Card[cite: 3]
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Wallet Balance", style: TextStyle(color: Colors.white54, fontSize: 13)),
                                  SizedBox(height: 6),
                                  Text("₹847.06", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.account_balance_wallet_outlined, color: brandBlue, size: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quick Recharge Section[cite: 3]
                        const Text("Quick Recharge", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Recharge Amount", style: TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAmountChip("₹200"),
                            _buildAmountChip("₹500"),
                            _buildAmountChip("₹1000"),
                            _buildAmountChip("₹2000"),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Custom Amount Section[cite: 3]
                        const Text("Custom Amount", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            onChanged: (val) {
                              setState(() {
                                _selectedAmount = ''; // Clear chips if typing custom amount
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text("₹", style: TextStyle(color: Colors.white54, fontSize: 18)),
                              ),
                              hintText: "Enter Custom Amount",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Payment Method Section[cite: 3]
                        const Text("Payment Method", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildPaymentTile(Icons.qr_code_scanner, "UPI Payment", cardBgColor),
                        const SizedBox(height: 10),
                        _buildPaymentTile(Icons.credit_card, "Debit / Credit Card", cardBgColor),
                        const SizedBox(height: 10),
                        _buildPaymentTile(Icons.account_balance, "Net Banking", cardBgColor),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // --- Footer (Proceed to Pay) ---[cite: 3]
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      const Text(
                        "Secure payments powered by Razorpay",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Proceed to Pay",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Quick Recharge Chips[cite: 3]
  Widget _buildAmountChip(String amount) {
    final bool isSelected = _selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _customAmountController.clear(); // Clear custom text if chip is tapped
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB).withOpacity(0.2) : const Color(0xFF161B22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white10,
            width: 1,
          ),
        ),
        child: Text(
          amount,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Helper widget for Payment Method Tiles[cite: 3]
  Widget _buildPaymentTile(IconData icon, String title, Color cardBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardBgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.arrow_forward, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}