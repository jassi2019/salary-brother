import 'package:get/get_utils/get_utils.dart';

/// Base URLs, the platform prefix and the auth headers.
///
/// The backend is the Salary Brother CRM, which mirrors the SalaryUncle CRM
/// endpoint for endpoint — only the host differs. Every request goes to
/// `<base>/<platform prefix>/<endpoint>`, where the prefix is `/andrd` on
/// Android and `/ios` on iOS.
///
/// Two paths on the same host are easy to confuse:
///  * `/api` — what this app talks to. Unverified for this host: SalaryUncle's
///    CRM serves its JSON API under `/api`, and this mirrors that, but the
///    Salary Brother CRM has not been confirmed to do the same. Checked
///    2026-10-11: `crm.salarybrother.com/apply` returns 404, so the CRM may
///    not be deployed yet.
///  * `/apply` — described as the page where leads land. The app does not call
///    it.
class ApiConfig {
  ApiConfig._();

  /// Flip to true to point the app at the UAT host.
  static const bool isDev = false;

  static const String _host = 'https://crm.salarybrother.com';

  /// SalaryUncle points UAT and prod at the same host; mirror that until a
  /// separate Salary Brother UAT host exists.
  static const String _uatBaseUrl = '$_host/api';
  static const String _prodBaseUrl = '$_host/api';

  /// The CRM page where leads land. Staff-facing, opened in a browser — not an
  /// API path. Kept here so nobody mistakes it for one again.
  static const String leadsPageUrl = '$_host/apply';

  static const String _androidPrefix = '/andrd';
  static const String _iosPrefix = '/ios';

  static String get baseUrl => isDev ? _uatBaseUrl : _prodBaseUrl;

  /// `/andrd` or `/ios`. Empty on web and desktop, which the CRM does not
  /// namespace by platform.
  static String get platformPrefix {
    if (GetPlatform.isAndroid) return _androidPrefix;
    if (GetPlatform.isIOS) return _iosPrefix;
    return '';
  }

  /// Builds the full URL for [endpoint]: base + platform prefix + path.
  ///
  /// Strips any leading slash on [endpoint] before joining, because the CRM
  /// rejects the doubled `//` that would otherwise appear.
  static String url(String endpoint) =>
      '$baseUrl$platformPrefix/${_trimSlashes(endpoint)}';

  /// Builds a URL without the platform prefix, for the Aadhaar OKYC module,
  /// which is mounted directly under the API root.
  static String unprefixedUrl(String endpoint) =>
      '$baseUrl/${_trimSlashes(endpoint)}';

  static String _trimSlashes(String endpoint) {
    var path = endpoint;
    while (path.startsWith('/')) {
      path = path.substring(1);
    }
    return path;
  }

  // --- Auth headers -------------------------------------------------------
  //
  // The CRM uses two static `Auth` keys, one platform-dependent and one not,
  // plus the customer's `Authtoken` after login. Which endpoint takes which is
  // irregular — see the table on `AuthMode`.
  //
  // TODO: fill these in when the CRM issues this app's keys.
  //
  // Verified against the live CRM on 2026-10-11: it accepts a request with no
  // `Auth` header at all, but answers `Status: 4 "Unauthorized Request!"` to a
  // wrong one. So a placeholder is worse than nothing — and because Status 4
  // means "log out", sending one bounced the customer back to login. The
  // header is therefore omitted while these are empty.

  /// The platform-dependent key (`apiHeader1` upstream).
  static const String _platformAuthKeyAndroid = '';
  static const String _platformAuthKeyIos = '';

  /// The single static key, same on every platform (`apiHeader` upstream).
  static const String _generalAuthKey = '';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers carrying the platform-dependent key. Used by login, OTP, resend,
  /// payment verification, the version check and `fetchOkycData`.
  static Map<String, String> get loginHeaders =>
      _withAuth(GetPlatform.isIOS ? _platformAuthKeyIos : _platformAuthKeyAndroid);

  /// Headers carrying the general static key. Used by `getOkycOtp` and
  /// `feedback`.
  static Map<String, String> get staticHeaders => _withAuth(_generalAuthKey);

  /// Adds the `Auth` header only when there is a real key to send.
  static Map<String, String> _withAuth(String key) => {
        ..._jsonHeaders,
        if (key.isNotEmpty) 'Auth': key,
      };

  /// Headers for endpoints that need the logged-in customer's token.
  static Map<String, String> tokenHeaders(String token) => {
        ..._jsonHeaders,
        'Authtoken': token,
      };

  /// True while this app has no `Auth` keys of its own. Requests still work —
  /// the header is simply left off — but the CRM is treating them as
  /// unauthenticated, which is not what should ship.
  static bool get hasPlaceholderKeys =>
      _generalAuthKey.isEmpty ||
      _platformAuthKeyAndroid.isEmpty ||
      _platformAuthKeyIos.isEmpty;
}
