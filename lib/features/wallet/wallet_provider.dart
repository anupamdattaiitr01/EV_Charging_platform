import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  // 1. The hidden data (Changed to double for accurate currency representation)
  // I set the default to 847.06 to match your UI's screenshot exactly!
  double _balance = 847.06;

  // 2. A safe way for the UI to read the data
  double get balance => _balance;

  // 3. The action function (Renamed to match the wallet_page call)
  void addBalance(double amount) {
    _balance += amount;

    // THE MEGAPHONE: This tells all listening widgets to redraw immediately!
    notifyListeners();
  }
}