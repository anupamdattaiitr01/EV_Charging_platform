import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';

// IMPORTANT: Adjust this import if your wallet provider is located elsewhere
import 'wallet_provider.dart';
// IMPORT THE NEW PAGE WE JUST CREATED
import 'razorpay_checkout_page.dart';

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
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  // --- NEW ROUTING LOGIC ---
  void _navigateToCheckout() {
    int amount = 0;

    // 1. Determine which amount to use (Chip vs Custom Field)
    if (_selectedAmount.isNotEmpty) {
      amount = int.tryParse(_selectedAmount.replaceAll('₹', '')) ?? 0;
    } else {
      amount = int.tryParse(_customAmountController.text) ?? 0;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or enter a valid amount"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Navigate to the new Checkout Verification Page, passing the amount!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayCheckoutPage(amount: amount.toDouble()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final translator = Provider.of<DynamicTranslationProvider>(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

    final currentBalance = Provider.of<WalletProvider>(context).balance;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Positioned(
            top: -120, left: -50, right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/Ellipse1.png', fit: BoxFit.cover, height: 400),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        onPressed: widget.onBackToHome,
                      ),
                      Text(
                        translator.translate("Wallet Recharge"),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.history, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: cardBgColor.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(translator.translate("Wallet Balance"), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text("₹${currentBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.account_balance_wallet_outlined, color: brandBlue, size: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(translator.translate("Quick Recharge"), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(translator.translate("Recharge Amount"), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAmountChip("₹200"), _buildAmountChip("₹500"), _buildAmountChip("₹1000"), _buildAmountChip("₹2000"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(translator.translate("Custom Amount"), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            onChanged: (val) => setState(() => _selectedAmount = ''),
                            decoration: InputDecoration(
                              prefixIcon: Padding(padding: const EdgeInsets.all(14.0), child: Text(translator.translate("₹"), style: const TextStyle(color: Colors.white54, fontSize: 18))),
                              hintText: translator.translate("Enter Custom Amount"), hintStyle: const TextStyle(color: Colors.white38, fontSize: 14), border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(translator.translate("Payment Method"), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildPaymentTile(Icons.qr_code_scanner, "UPI Payment", cardBgColor, translator),
                        const SizedBox(height: 10),
                        _buildPaymentTile(Icons.credit_card, "Debit / Credit Card", cardBgColor, translator),
                        const SizedBox(height: 10),
                        _buildPaymentTile(Icons.account_balance, "Net Banking", cardBgColor, translator),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Text(translator.translate("Secure payments powered by Razorpay"), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _navigateToCheckout, // Connected to the navigation function
                          style: ElevatedButton.styleFrom(backgroundColor: brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text(translator.translate("Proceed to Pay"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildAmountChip(String amount) {
    final bool isSelected = _selectedAmount == amount;
    return GestureDetector(
      onTap: () => setState(() { _selectedAmount = amount; _customAmountController.clear(); }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB).withOpacity(0.2) : const Color(0xFF161B22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.white10, width: 1),
        ),
        child: Text(amount, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildPaymentTile(IconData icon, String title, Color cardBgColor, DynamicTranslationProvider translator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: cardBgColor.withOpacity(0.6), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, color: Colors.white70, size: 22), const SizedBox(width: 16), Text(translator.translate(title), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))]),
          const Icon(Icons.arrow_forward, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}