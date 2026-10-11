import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/utils/brand_config.dart';

void main() {
  group('contact details', () {
    test('the support channels are filled in', () {
      expect(BrandConfig.hasPhone, isTrue);
      expect(BrandConfig.hasWhatsapp, isTrue);
      expect(BrandConfig.hasEmail, isTrue);
      expect(BrandConfig.hasAnyContact, isTrue);
    });

    test('phone numbers are dialable: + country code, no spaces', () {
      // url_launcher's tel: scheme chokes on spaces and brackets.
      for (final number in [BrandConfig.phone, BrandConfig.whatsapp]) {
        expect(
          RegExp(r'^\+\d{10,15}$').hasMatch(number),
          isTrue,
          reason: '"$number" is not a bare +E.164 number',
        );
      }
    });

    test('the email is on the brand domain', () {
      expect(BrandConfig.email, endsWith('@salarybrother.com'));
    });

    test('no SalaryUncle contact details leaked across', () {
      final strings = [
        BrandConfig.email,
        BrandConfig.phone,
        BrandConfig.whatsapp,
        BrandConfig.website,
        BrandConfig.companyAddress,
        BrandConfig.privacyPolicyUrl,
        BrandConfig.termsUrl,
      ];

      for (final value in strings) {
        final lower = value.toLowerCase();
        expect(lower, isNot(contains('salaryuncle')));
        expect(lower, isNot(contains('suryaloan')));
        expect(lower, isNot(contains('salarytopup')));
        expect(lower, isNot(contains('tejas')));
      }
    });
  });

  group('legal links', () {
    test('both sit under the brand website', () {
      expect(BrandConfig.privacyPolicyUrl, startsWith(BrandConfig.website));
      expect(BrandConfig.termsUrl, startsWith(BrandConfig.website));
    });
  });

  group('release gate', () {
    test('hasPlaceholders is true while the NBFC partner is unnamed', () {
      // Guards the release check itself: once the partner and the registered
      // entity are filled in, this test must be updated to expect false.
      expect(BrandConfig.nbfcPartnerName, startsWith('['));
      expect(BrandConfig.hasPlaceholders, isTrue);
    });
  });
}
