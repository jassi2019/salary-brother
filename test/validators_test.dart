import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/utils/validators.dart';

void main() {
  group('Validators.mobile', () {
    test('accepts a 10-digit number starting 6-9', () {
      expect(Validators.mobile('9876543210'), isNull);
      expect(Validators.mobile('6000000000'), isNull);
    });

    test('rejects wrong length, wrong prefix, letters and empty input', () {
      expect(Validators.mobile('98765432'), isNotNull);
      expect(Validators.mobile('98765432101'), isNotNull);
      expect(Validators.mobile('5876543210'), isNotNull);
      expect(Validators.mobile('98765abcde'), isNotNull);
      expect(Validators.mobile(''), isNotNull);
      expect(Validators.mobile(null), isNotNull);
    });
  });

  group('Validators.otp', () {
    test('accepts exactly six digits', () {
      expect(Validators.otp('482913'), isNull);
    });

    test('rejects short, long and non-numeric codes', () {
      expect(Validators.otp('4829'), isNotNull);
      expect(Validators.otp('4829134'), isNotNull);
      expect(Validators.otp('48291a'), isNotNull);
    });
  });

  group('Validators.pan', () {
    test('accepts the AAAAA9999A shape, case-insensitively', () {
      expect(Validators.pan('ABCDE1234F'), isNull);
      expect(Validators.pan('abcde1234f'), isNull);
    });

    test('rejects a malformed PAN', () {
      expect(Validators.pan('ABCD1234F'), isNotNull);
      expect(Validators.pan('ABCDE12345'), isNotNull);
      expect(Validators.pan(''), isNotNull);
    });
  });

  group('Validators.aadhaar', () {
    test('accepts 12 digits, with or without spaces', () {
      expect(Validators.aadhaar('123456789012'), isNull);
      expect(Validators.aadhaar('1234 5678 9012'), isNull);
    });

    test('rejects anything that is not 12 digits', () {
      expect(Validators.aadhaar('12345678901'), isNotNull);
      expect(Validators.aadhaar('abcd56789012'), isNotNull);
    });
  });

  group('Validators.email', () {
    test('accepts an ordinary address', () {
      expect(Validators.email('rahul@example.com'), isNull);
      expect(Validators.email('rahul.k+tag@mail.co.in'), isNull);
    });

    test('rejects an address with no domain or no user', () {
      expect(Validators.email('rahul@'), isNotNull);
      expect(Validators.email('@example.com'), isNotNull);
      expect(Validators.email('rahul.example.com'), isNotNull);
    });
  });
}
