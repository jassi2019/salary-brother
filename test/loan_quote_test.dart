import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/models/loan_quote.dart';

void main() {
  const pricing = LoanPricing();

  group('published defaults', () {
    test('match the terms on the website', () {
      // 2% one-time processing fee, interest per day, 7-30 day tenures,
      // flat ₹250 late fee. If any of these change on the site, change here.
      expect(pricing.processingFeePct, 2.0);
      expect(pricing.gstPct, 18.0);
      expect(pricing.lateFee, 250);
      expect(pricing.tenureOptions.first, 7);
      expect(pricing.tenureOptions.last, 30);
      expect(pricing.maxAmount, 30000);
    });
  });

  group('LoanQuote', () {
    test('prices a 20,000 / 30-day loan on the published terms', () {
      final quote = LoanQuote.from(
        amount: 20000,
        days: 30,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      // 2% of 20,000
      expect(quote.processingFee, 400);
      // 18% GST on the fee
      expect(quote.gst, 72);
      // 1% per day for 30 days
      expect(quote.interest, 6000);

      expect(quote.netDisbursed, 20000 - 400 - 72);
      expect(quote.totalRepayable, 26000);
      expect(quote.totalCost, 6000 + 400 + 72);
    });

    test('a 0.25% rate costs a quarter of the 1% rate', () {
      // The published rate runs 0.25% to 1% by profile.
      const best = LoanPricing(ratePerDay: 0.25);
      final cheap = LoanQuote.from(
        amount: 20000,
        days: 30,
        pricing: best,
        today: DateTime(2026, 10, 11),
      );

      expect(cheap.interest, 1500);
      expect(cheap.totalRepayable, 21500);
    });

    test('due date is the tenure added to today', () {
      final quote = LoanQuote.from(
        amount: 10000,
        days: 30,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      expect(quote.dueDate, DateTime(2026, 11, 10));
    });

    test('interest is charged only for the days held', () {
      LoanQuote at(int days) => LoanQuote.from(
            amount: 10000,
            days: days,
            pricing: pricing,
            today: DateTime(2026, 10, 11),
          );

      // "a six-day loan costs less than an eight-day one"
      expect(at(6).interest, lessThan(at(8).interest));
      expect(at(7).interest, 700);
    });

    test('APR annualises the cost over what was actually received', () {
      final quote = LoanQuote.from(
        amount: 10000,
        days: 30,
        pricing: pricing,
        today: DateTime(2026, 10, 11),
      );

      // interest 3,000 + fee 200 + GST 36 = 3,236 on 9,764 over 30 days
      expect(quote.totalCost, 3236);
      expect(quote.netDisbursed, 9764);
      expect(quote.apr, closeTo(3236 / 9764 * 365 / 30 * 100, 0.01));
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

  group('LoanPricing.fromJson', () {
    test('takes the server\'s per-borrower terms', () {
      final parsed = LoanPricing.fromJson({
        'min_loan_amount': '3000',
        'max_loan_amount': '50000',
        'interest_rate_per_day': '0.5',
        'processing_fee_pct': '2.5',
      });

      expect(parsed.minAmount, 3000);
      expect(parsed.maxAmount, 50000);
      expect(parsed.ratePerDay, 0.5);
      expect(parsed.processingFeePct, 2.5);
    });

    test('falls back to the published defaults for missing fields', () {
      final parsed = LoanPricing.fromJson({'max_loan_amount': 40000});

      expect(parsed.maxAmount, 40000);
      expect(parsed.minAmount, pricing.minAmount);
      expect(parsed.processingFeePct, pricing.processingFeePct);
      expect(parsed.tenureOptions, pricing.tenureOptions);
    });

    test('keeps only the tenures the server allows', () {
      final parsed = LoanPricing.fromJson({
        'min_loan_tenure': 7,
        'max_loan_tenure': 21,
      });

      expect(parsed.tenureOptions, [7, 15, 21]);
    });

    test('a range outside the published choices offers its endpoints', () {
      final parsed = LoanPricing.fromJson({
        'min_loan_tenure': 45,
        'max_loan_tenure': 60,
      });

      // Never an empty picker.
      expect(parsed.tenureOptions, isNotEmpty);
      expect(parsed.tenureOptions, [45, 60]);
    });

    test('tolerates decimals and junk in numeric fields', () {
      final parsed = LoanPricing.fromJson({
        'max_loan_tenure': '30.0',
        'max_loan_amount': 'not a number',
      });

      expect(parsed.tenureOptions.last, 30);
      expect(parsed.maxAmount, pricing.maxAmount);
    });
  });
}
