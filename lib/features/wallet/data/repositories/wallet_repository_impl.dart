import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../domain/repositories/i_wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  late Razorpay _razorpay;
  Completer<void>? _paymentCompleter;

  WalletRepositoryImpl() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.completeError("Payment Failed: ${response.message}");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Treat external wallet selection as an error for this flow, or handle appropriately
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.completeError("External Wallet Selected: ${response.walletName}");
    }
  }

  @override
  Future<void> initiatePayment(double amount) async {
    final apiKey = dotenv.env['RAZORPAY_TEST_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("Razorpay Test Key not found in .env file");
    }

    _paymentCompleter = Completer<void>();

    var options = {
      'key': apiKey,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'EV Charge Platform',
      'description': 'Wallet Recharge Test',
      'prefill': {
        'contact': '8888877777',
        'email': 'anupam@test.com'
      },
      'theme': {
        'color': '#2563EB'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      throw Exception('SDK Error launching Razorpay: $e');
    }

    return _paymentCompleter!.future;
  }

  // Call this when shutting down the app or logging out to clean up listeners
  void dispose() {
    _razorpay.clear();
  }
}