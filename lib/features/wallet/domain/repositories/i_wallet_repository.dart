abstract class IWalletRepository {
  /// Initiates a payment process for the given amount.
  Future<void> initiatePayment(double amount);
}