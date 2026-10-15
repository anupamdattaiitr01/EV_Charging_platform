import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  // 1. The hidden data
  int _balance = 500;

  // 2. A safe way for the UI to read the data
  int get balance => _balance;

  // 3. The action function
  void addFunds(int amount) {
    _balance += amount;

    // THE MEGAPHONE: This tells all listening widgets to redraw immediately!
    notifyListeners();
  }
}