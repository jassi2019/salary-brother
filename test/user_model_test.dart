import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/models/user_model.dart';

/// A `getDashboardData` payload shaped the way the CRM actually sends it.
Map<String, dynamic> _payload({
  Map<String, dynamic>? profile,
  Map<String, dynamic>? employment,
  Object? registered = '1',
  Object? nextEvent = 'completed',
}) =>
    {
      'cust_profile_id': 'XW5UOA0yAGs-',
      'next_event_name': nextEvent,
      'registration_successful': registered,
      'application_submitted': '0',
      'profile_filled_percent': 60,
      'application_filled_percent': 25,
      'profile_pic': 'https://crm.salarybrother.com/uploads/selfie.jpg',
      'profile_details': profile ??
          {
            'first_name': 'Rahul',
            'middle_name': '',
            'last_name': 'Kumar',
            'mobile': '9876543210',
            'personal_email': 'rahul@example.com',
            'pancard': 'ABCDE1234F',
            // The CRM sends income as a string.
            'monthly_income': '40000',
          },
      'customer_employment_details':
          employment ?? {'employer_name': 'Acme Pvt Ltd'},
      'bureau': {'cibilScore': 742},
    };

void main() {
  group('UserModel.fromJson reads the CRM shape', () {
    test('pulls the nested profile_details group', () {
      // Regression: the model read flat keys like `credit_limit` and
      // `kyc_stage`, which the CRM never sends — so every field was null and
      // the dashboard showed "Welcome" and a dash, however far along the
      // customer was.
      final user = UserModel.fromJson(_payload());

      expect(user.id, 'XW5UOA0yAGs-');
      expect(user.name, 'Rahul Kumar');
      expect(user.mobile, '9876543210');
      expect(user.email, 'rahul@example.com');
      expect(user.pan, 'ABCDE1234F');
      expect(user.employerName, 'Acme Pvt Ltd');
      expect(user.monthlyIncome, 40000);
      expect(user.cibilScore, 742);
      expect(user.initials, 'RK');
    });

    test('joins the name without a gap for an empty middle name', () {
      final user = UserModel.fromJson(_payload());
      expect(user.name, isNot(contains('  ')));
    });

    test('keeps a middle name when there is one', () {
      final user = UserModel.fromJson(_payload(profile: {
        'first_name': 'Rahul',
        'middle_name': 'Singh',
        'last_name': 'Kumar',
      }));

      expect(user.name, 'Rahul Singh Kumar');
      // First and last, not first and middle.
      expect(user.initials, 'RK');
    });

    test('survives the groups the CRM omits before their step is done', () {
      // customer_employment_details is absent until employment is filled in.
      final user = UserModel.fromJson({
        'cust_profile_id': 'abc',
        'profile_details': {'first_name': 'Asha'},
      });

      expect(user.name, 'Asha');
      expect(user.employerName, isNull);
      expect(user.monthlyIncome, isNull);
      expect(user.cibilScore, isNull);
    });

    test('treats empty and "null" strings as absent', () {
      final user = UserModel.fromJson(_payload(profile: {
        'first_name': 'Asha',
        'personal_email': '',
        'pancard': 'null',
      }));

      expect(user.email, isNull);
      expect(user.pan, isNull);
    });

    test('falls back to SB when there is no name at all', () {
      final user = UserModel.fromJson(const {});
      expect(user.initials, 'SB');
      expect(user.name, isNull);
    });
  });

  group('the selfie', () {
    test('is read from profile_pic', () {
      final user = UserModel.fromJson(_payload());

      expect(user.hasPhoto, isTrue);
      expect(user.profilePicUrl, endsWith('selfie.jpg'));
    });

    test('is absent before the upload', () {
      final user = UserModel.fromJson(const {'profile_pic': ''});
      expect(user.hasPhoto, isFalse);
    });
  });

  group('progress follows the CRM, not a local guess', () {
    test('uses the application percent once registration is done', () {
      final user = UserModel.fromJson(_payload(nextEvent: 'banking_details'));

      expect(user.isRegistered, isTrue);
      expect(user.progressPercent, 25);
    });

    test('uses the profile percent while still registering', () {
      final user = UserModel.fromJson(
        _payload(registered: '0', nextEvent: 'income_details'),
      );

      expect(user.isRegistered, isFalse);
      expect(user.progressPercent, 60);
    });

    test('stays on the profile percent at the register_now step itself', () {
      // Registered but still on register_now means the CRM is mid-handover.
      final user = UserModel.fromJson(_payload(nextEvent: 'register_now'));
      expect(user.progressPercent, 60);
    });

    test('flags are read from 1, "1" and true alike', () {
      expect(UserModel.fromJson(_payload(registered: 1)).isRegistered, isTrue);
      expect(UserModel.fromJson(_payload(registered: true)).isRegistered,
          isTrue);
      expect(UserModel.fromJson(_payload(registered: '0')).isRegistered,
          isFalse);
    });

    test('completion comes from next_event_name', () {
      expect(UserModel.fromJson(_payload()).isComplete, isTrue);
      expect(
        UserModel.fromJson(_payload(nextEvent: 'selfie_upload')).isComplete,
        isFalse,
      );
    });
  });
}
