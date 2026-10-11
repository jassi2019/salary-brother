import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/models/loan_quote.dart';

void main() {
  const pricing = LoanPricing();

  group('LoanQuote', () {
    test('prices a 20,000 / 30-day loan the way the design does', () {
      final quote = LoanQuote.from(
        amount: 20000,
        days: 30,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      // 10% of 20,000
      expect(quote.processingFee, 2000);
      // 18% GST on the fee
      expect(quote.gst, 360);
      // 1% per day for 30 days
      expect(quote.interest, 6000);

      expect(quote.netDisbursed, 20000 - 2000 - 360);
      expect(quote.totalRepayable, 26000);
      expect(quote.totalCost, 6000 + 2000 + 360);
    });

    test('due date is the tenure added to today', () {
      final quote = LoanQuote.from(
        amount: 10000,
        days: 40,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      expect(quote.dueDate, DateTime(2026, 11, 20));
    });

    test('APR annualises the cost over what was actually received', () {
      final quote = LoanQuote.from(
        amount: 10000,
        days: 30,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      // interest 3,000 + fee 1,000 + GST 180 = 4,180 on 8,820 over 30 days
      expect(quote.totalCost, 4180);
      expect(quote.netDisbursed, 8820);
      expect(quote.apr, closeTo(4180 / 8820 * 365 / 30 * 100, 0.01));
      expect(quote.aprLabel.endsWith('%'), isTrue);
    });

    test('APR is unavailable when the charges swallow the principal', () {
      const brutal = LoanPricing(processingFeePct: 90, gstPct: 18);
      final quote = LoanQuote.from(
        amount: 10000,
        days: 30,
        pricing: brutal,
        today: DateTime(2026, 10, 11),
      );

      expect(quote.netDisbursed, lessThanOrEqualTo(0));
      expect(quote.apr, isNull);
      expect(quote.aprLabel, '—');
    });

    test('a zero-interest, zero-fee loan repays exactly the principal', () {
      const free = LoanPricing(ratePerDay: 0, processingFeePct: 0);
      final quote = LoanQuote.from(
        amount: 15000,
        days: 15,
        pricing: free,
        today: DateTime(2026, 10, 11),
      );

      expect(quote.netDisbursed, 15000);
      expect(quote.totalRepayable, 15000);
      expect(quote.totalCost, 0);
    });
  });
}
