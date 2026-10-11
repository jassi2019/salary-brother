import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/utils/formatters.dart';

void main() {
  group('Formatters.rupees', () {
    test('groups digits the Indian way', () {
      expect(Formatters.rupees(20000), '₹20,000');
      expect(Formatters.rupees(100000), '₹1,00,000');
      expect(Formatters.rupees(0), '₹0');
    });

    test('rounds fractional amounts', () {
      expect(Formatters.rupees(1999.6), '₹2,000');
    });
  });

  group('Formatters.maskAccount', () {
    test('keeps only the last four digits', () {
      expect(Formatters.maskAccount('50100234564521'), '•••• 4521');
    });

    test('leaves a short string alone', () {
      expect(Formatters.maskAccount('451'), '451');
    });
  });

  group('Formatters.mobile', () {
    test('splits a 10-digit number 5 + 5', () {
      expect(Formatters.mobile('9876543210'), '98765 43210');
    });

    test('leaves anything else untouched', () {
      expect(Formatters.mobile('98765'), '98765');
    });
  });

  group('Formatters.date', () {
    test('renders as "d MMM yyyy"', () {
      expect(Formatters.date(DateTime(2026, 11, 20)), '20 Nov 2026');
    });
  });
}
