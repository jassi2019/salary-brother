import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/services/api/api_result.dart';

void main() {
  group('CrmStatus.parse', () {
    test('maps the CRM status codes', () {
      expect(CrmStatus.parse(1), CrmStatus.ok);
      expect(CrmStatus.parse('1'), CrmStatus.ok);
      expect(CrmStatus.parse(3), CrmStatus.bounceToDashboard);
      expect(CrmStatus.parse(4), CrmStatus.logout);
    });

    test('anything unrecognised is a failure, not a success', () {
      expect(CrmStatus.parse(0), CrmStatus.failed);
      expect(CrmStatus.parse(2), CrmStatus.failed);
      expect(CrmStatus.parse(null), CrmStatus.failed);
      expect(CrmStatus.parse(''), CrmStatus.failed);
      expect(CrmStatus.parse('ok'), CrmStatus.failed);
    });
  });

  group('ApiResult', () {
    test('a success carries its data and asks for no redirect', () {
      const result = ApiResult.success({'app_login_token': 'abc'});

      expect(result.isSuccess, isTrue);
      expect(result.data?['app_login_token'], 'abc');
      expect(result.shouldLogout, isFalse);
      expect(result.shouldBounceToDashboard, isFalse);
    });

    test('a failure carries the message and no data', () {
      const result = ApiResult<Map<String, dynamic>>.failure('Invalid OTP');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Invalid OTP');
      expect(result.data, isNull);
    });

    test('status 4 asks for a logout', () {
      const result = ApiResult<Map<String, dynamic>>.failure(
        'Session expired',
        status: CrmStatus.logout,
      );

      expect(result.shouldLogout, isTrue);
      expect(result.shouldBounceToDashboard, isFalse);
    });

    test('status 3 asks for a bounce to the dashboard, not a logout', () {
      const result = ApiResult<Map<String, dynamic>>.failure(
        'Please start from the dashboard',
        status: CrmStatus.bounceToDashboard,
      );

      expect(result.shouldBounceToDashboard, isTrue);
      expect(result.shouldLogout, isFalse);
    });

    test('an HTTP 401 asks for a logout even without a CRM status', () {
      const result = ApiResult<Map<String, dynamic>>.failure(
        'Unauthorised',
        statusCode: 401,
      );

      expect(result.shouldLogout, isTrue);
    });
  });
}
