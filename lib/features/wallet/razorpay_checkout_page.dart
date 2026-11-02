import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// IMPORTANT: Adjust this import to match the actual path to your wallet provider!
import 'wallet_provider.dart';

class RazorpayCheckoutPage extends StatefulWidget {
  final double amount; // this variable with store the value of the amount passed from the app page
  // that is why final is used to show that it will have value later on
  // checks on the value is done in the previous wallet page

  const RazorpayCheckoutPage({super.key, required this.amount});

  @override
  State<RazorpayCheckoutPage> createState() => _RazorpayCheckoutPageState();
}

class _RazorpayCheckoutPageState extends State<RazorpayCheckoutPage> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay(); // instance of razorpay SDK is created
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess); // This event handler is called when the payment is successful
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError); // This event handler is called when the payment is not successful
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet); // This event handler is called when the payment is successful
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Successful handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);

    // first update the wallet
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.addBalance(widget.amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Success! ₹${widget.amount} added. ID: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  // UnSuccessful handler
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // External Wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // This is the initiating point of the transaction
  void _startPayment() {
    final apiKey = dotenv.env['RAZORPAY_TEST_KEY'];


    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Razorpay Test Key not found in .env file! Did you await dotenv.load()?"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // these are the details that are needed for calling the razorpay API
    var options = {
      'key': apiKey,
      'amount': (widget.amount * 100).toInt(),
      'name': 'EV Charge Platform',
      'description': 'Wallet Recharge Test',
      'prefill': {
        'contact': '9876543210',
        'email': 'anupam@test.com'
      },
      'theme': {
        'color': '#2563EB'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // 2. Turn off the spinner and show the exact error if the SDK fails
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("SDK Error: $e"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      debugPrint('Error launching Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Checkout Verification', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, color: Color(0xFF00E676), size: 48),
                const SizedBox(height: 16),
                const Text("You are about to recharge", style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 8),
                Text("₹${widget.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Pay Securely with Razorpay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}