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

  group('refusal vs transport failure', () {
    test('a CRM refusal is distinguishable from the network dying', () {
      // Status 3 and 4 mean the CRM answered and decided something.
      for (final status in [CrmStatus.logout, CrmStatus.bounceToDashboard]) {
        final result = ApiResult<Map<String, dynamic>>.failure(
          'Please log in again',
          status: status,
        );

        expect(result.isCrmRefusal, isTrue, reason: '$status');
        expect(result.isTransportFailure, isFalse, reason: '$status');
        expect(result.requiresRedirect, isTrue, reason: '$status');
      }
    });

    test('a timeout or dead connection is a transport failure', () {
      const result = ApiResult<Map<String, dynamic>>.failure(
        'No internet connection',
      );

      expect(result.isTransportFailure, isTrue);
      expect(result.isCrmRefusal, isFalse);
      // Nothing to redirect to — the caller should offer a retry.
      expect(result.requiresRedirect, isFalse);
    });

    test('a success is neither', () {
      const result = ApiResult.success({'ok': true});

      expect(result.isCrmRefusal, isFalse);
      expect(result.isTransportFailure, isFalse);
      expect(result.requiresRedirect, isFalse);
    });

    test('status 3 redirects without logging out', () {
      const result = ApiResult<Map<String, dynamic>>.failure(
        'Start from the dashboard',
        status: CrmStatus.bounceToDashboard,
      );

      expect(result.requiresRedirect, isTrue);
      expect(result.shouldLogout, isFalse);
    });
  });
}
