import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/controllers/loan_controller.dart';
import 'package:salary_brother/models/loan_quote.dart';

void main() {
  group('LoanController', () {
    late LoanController controller;

    setUp(() {
      controller = LoanController()..onInit();
    });

    test('opens on the mid-range amount and a 30-day tenure', () {
      expect(controller.amount.value, 20000);
      expect(controller.days.value, 30);
    });

    test('stepping stays inside the min and max', () {
      controller.setAmount(5000);
      controller.decrement();
      expect(controller.amount.value, 5000);

      controller.setAmount(100000);
      controller.increment();
      expect(controller.amount.value, 100000);
    });

    test('an out-of-range amount is clamped, not accepted', () {
      controller.setAmount(999999);
      expect(controller.amount.value, 100000);

      controller.setAmount(100);
      expect(controller.amount.value, 5000);
    });

    test('an off-grid amount snaps to the nearest step', () {
      controller.setAmount(12400);
      expect(controller.amount.value, 12000);

      controller.setAmount(12600);
      expect(controller.amount.value, 13000);
    });

    test('fillFraction spans 0 to 1 across the range', () {
      controller.setAmount(5000);
      expect(controller.fillFraction, 0);

      controller.setAmount(100000);
      expect(controller.fillFraction, 1);

      // Mid-range. The amount snaps to the 1,000 step first, so allow for
      // that rather than pinning an exact fraction.
      controller.setAmount(52500);
      expect(controller.fillFraction, closeTo(0.5, 0.03));
    });

    test('a new limit raises the ceiling and keeps the amount valid', () {
      controller.setAmount(100000);
      controller.applyLimit(150000);

      expect(controller.pricing.value.maxAmount, 150000);
      expect(controller.amount.value, 100000);
    });

    test('a lower limit pulls an over-limit amount back down', () {
      controller.setAmount(100000);
      controller.applyLimit(15000);

      expect(controller.pricing.value.maxAmount, 15000);
      expect(controller.amount.value, 15000);
    });

    test('a limit below the floor is ignored', () {
      controller.applyLimit(1000);
      expect(controller.pricing.value.maxAmount, 100000);
    });

    test('presets never exceed the current limit', () {
      controller.applyLimit(12000);
      expect(controller.presets.every((p) => p <= 12000), isTrue);
    });

    test('the quote follows the selected amount and tenure', () {
      controller.setAmount(10000);
      controller.setDays(7);

      final quote = controller.quote;
      expect(quote.amount, 10000);
      expect(quote.days, 7);
      expect(quote.interest, 700);
    });

    test('a custom pricing config is respected', () {
      final custom = LoanController(
        pricing: const LoanPricing(minAmount: 2000, maxAmount: 8000),
      )..onInit();

      expect(custom.amount.value, 8000);
      expect(custom.pricing.value.maxAmount, 8000);
    });
  });
}
