import 'package:get/get.dart';

import '../models/loan_quote.dart';

/// Drives the amount + tenure calculator on the Apply screen.
/// The maths lives in [LoanQuote] so it can be unit-tested on its own.
class LoanController extends GetxController {
  LoanController({LoanPricing pricing = const LoanPricing()})
      : pricing = pricing.obs;

  final Rx<LoanPricing> pricing;

  late final RxInt amount = pricing.value.minAmount.obs;
  late final RxInt days = pricing.value.tenureOptions.first.obs;

  @override
  void onInit() {
    super.onInit();
    // Open on a sensible mid-range amount, as the design does.
    amount.value = _clamp(20000);
    days.value = 30;
  }

  LoanQuote get quote => LoanQuote.from(
        amount: amount.value,
        days: days.value,
        pricing: pricing.value,
      );

  /// Slider position, 0.0 at the minimum amount and 1.0 at the limit.
  double get fillFraction {
    final p = pricing.value;
    final span = p.maxAmount - p.minAmount;
    if (span <= 0) return 0;
    return (amount.value - p.minAmount) / span;
  }

  List<int> get presets {
    final p = pricing.value;
    return [10000, 20000, p.maxAmount]
        .where((v) => v >= p.minAmount && v <= p.maxAmount)
        .toSet()
        .toList()
      ..sort();
  }

  void setAmount(int value) => amount.value = _clamp(value);

  void increment() => setAmount(amount.value + pricing.value.stepAmount);

  void decrement() => setAmount(amount.value - pricing.value.stepAmount);

  void setDays(int value) => days.value = value;

  /// Called once the server returns the borrower's real pre-approved limit.
  void applyLimit(int limit) {
    if (limit < pricing.value.minAmount) return;
    pricing.value = pricing.value.copyWith(maxAmount: limit);
    amount.value = _clamp(amount.value);
  }

  int _clamp(int value) {
    final p = pricing.value;
    final stepped = (value / p.stepAmount).round() * p.stepAmount;
    return stepped.clamp(p.minAmount, p.maxAmount);
  }
}
