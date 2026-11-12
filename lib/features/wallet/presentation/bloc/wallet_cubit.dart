import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_wallet_repository.dart';

// --- States ---
abstract class WalletState {}

class WalletInitial extends WalletState {
  final double balance;
  WalletInitial(this.balance);
}

class WalletProcessing extends WalletState {
  final double balance;
  WalletProcessing(this.balance);
}

class WalletPaymentSuccess extends WalletState {
  final double balance;
  final String paymentId;
  WalletPaymentSuccess(this.balance, this.paymentId);
}

class WalletPaymentError extends WalletState {
  final double balance;
  final String message;
  WalletPaymentError(this.balance, this.message);
}

// --- Cubit ---
class WalletCubit extends Cubit<WalletState> {
  final IWalletRepository _repository;

  // Starting balance matching your UI screenshot
  double _currentBalance = 847.06;

  WalletCubit(this._repository) : super(WalletInitial(847.06));

  double get balance => _currentBalance;

  Future<void> addFunds(double amount) async {
    emit(WalletProcessing(_currentBalance));

    try {
      await _repository.initiatePayment(amount);
      // Note: In this architecture, the repository throws an exception if payment fails.
      // If it succeeds, we update the balance.
      _currentBalance += amount;
      emit(WalletPaymentSuccess(_currentBalance, "PAYMENT_COMPLETED"));
    } catch (e) {
      emit(WalletPaymentError(_currentBalance, e.toString()));
    }
  }
}