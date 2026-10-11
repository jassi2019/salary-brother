import 'package:get/get_utils/get_utils.dart';

/// Base URLs, the platform prefix and the auth headers.
///
/// The backend is the Salary Brother CRM, which mirrors the SalaryUncle CRM:
/// every request goes to `<base>/<platform prefix>/<endpoint>`, where the
/// prefix is `/andrd` on Android and `/ios` on iOS.
class ApiConfig {
  ApiConfig._();

  /// Flip to true to point the app at the UAT host.
  static const bool isDev = false;

  static const String _uatBaseUrl = 'https://crm.salarybrother.com/api';
  static const String _prodBaseUrl = 'https://crm.salarybrother.com/api';

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
  // TODO: replace both placeholders with the Salary Brother CRM's own keys.
  // These are per-product and per-platform; do not reuse another product's.
  // Until they are filled in, every request will be rejected by the CRM.

  /// Static key for pre-login calls (sending and verifying the OTP).
  static const String _preLoginAuthKeyAndroid = 'REPLACE_ME_ANDROID_AUTH_KEY';
  static const String _preLoginAuthKeyIos = 'REPLACE_ME_IOS_AUTH_KEY';

  /// Static key for the general, non-login endpoints.
  static const String _generalAuthKey = 'REPLACE_ME_GENERAL_AUTH_KEY';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers for the login / OTP endpoints, before a token exists.
  static Map<String, String> get loginHeaders => {
        ..._jsonHeaders,
        'Auth': GetPlatform.isIOS ? _preLoginAuthKeyIos : _preLoginAuthKeyAndroid,
      };

  /// Headers for endpoints that take the static key rather than a token.
  static Map<String, String> get staticHeaders => {
        ..._jsonHeaders,
        'Auth': _generalAuthKey,
      };

  /// Headers for endpoints that need the logged-in customer's token.
  static Map<String, String> tokenHeaders(String token) => {
        ..._jsonHeaders,
        'Authtoken': token,
      };

  /// True while the auth keys are still placeholders, so the app can fail
  /// loudly in debug instead of silently 401-ing.
  static bool get hasPlaceholderKeys =>
      _generalAuthKey.startsWith('REPLACE_ME') ||
      _preLoginAuthKeyAndroid.startsWith('REPLACE_ME');
}
