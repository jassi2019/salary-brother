import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences. Call [init] once before runApp.
class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static const String _keyToken = 'token';
  static const String _keyProfileId = 'profile_id';
  // Spelled as the reference app spells it, so an existing install's data
  // still reads.
  static const String _keyMobile = 'mnumber';
  static const String _keyPancard = 'pancard';
  static const String _keyStepStage = 'step_stage';
  static const String _keyIsLogin = 'is_login';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyUtmSource = 'utm_source';
  static const String _keyLatLong = 'lat_long';
  static const String _keyOnboarded = 'onboarding_seen';
  static const String _keyDarkMode = 'isDarkMode';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- session ------------------------------------------------------------

  /// The CRM's `Data.app_login_token`, sent back as the `Authtoken` header.
  static String? get token => _prefs.getString(_keyToken);
  static Future<void> setToken(String value) =>
      _prefs.setString(_keyToken, value);

  static bool get isLoggedIn =>
      (_prefs.getBool(_keyIsLogin) ?? false) && (token ?? '').isNotEmpty;
  static Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(_keyIsLogin, value);

  /// The CRM's `cust_profile_id`, required in the body of most calls.
  static String? get profileId => _prefs.getString(_keyProfileId);
  static Future<void> setProfileId(String value) =>
      _prefs.setString(_keyProfileId, value);

  static String? get mobile => _prefs.getString(_keyMobile);
  static Future<void> setMobile(String value) =>
      _prefs.setString(_keyMobile, value);

  static String? get pancard => _prefs.getString(_keyPancard);
  static Future<void> setPancard(String value) =>
      _prefs.setString(_keyPancard, value);

  // --- journey ------------------------------------------------------------

  /// The CRM's `Data.next_step`: the `event_name` the customer must complete
  /// next. This is what decides which screen to open on launch.
  static String? get stepStage => _prefs.getString(_keyStepStage);
  static Future<void> setStepStage(String value) =>
      _prefs.setString(_keyStepStage, value);

  // --- device / attribution ----------------------------------------------

  static String? get fcmToken => _prefs.getString(_keyFcmToken);
  static Future<void> setFcmToken(String value) =>
      _prefs.setString(_keyFcmToken, value);

  static String? get utmSource => _prefs.getString(_keyUtmSource);
  static Future<void> setUtmSource(String value) =>
      _prefs.setString(_keyUtmSource, value);

  static String get latLong => _prefs.getString(_keyLatLong) ?? '0.0,0.0';
  static Future<void> setLatLong(String value) =>
      _prefs.setString(_keyLatLong, value);

  // --- onboarding ---------------------------------------------------------

  static bool get hasSeenOnboarding => _prefs.getBool(_keyOnboarded) ?? false;
  static Future<void> setOnboardingSeen() =>
      _prefs.setBool(_keyOnboarded, true);

  // --- theme --------------------------------------------------------------

  static bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;
  static Future<void> setDarkMode(bool value) =>
      _prefs.setBool(_keyDarkMode, value);

  /// Wipes the session on logout, keeping the device-level settings that are
  /// not tied to a customer: the theme choice (as the reference app does),
  /// plus the push token, attribution source and onboarding flag, which belong
  /// to the install rather than the account.
  static Future<void> clearSession() async {
    final dark = isDarkMode;
    final fcm = fcmToken;
    final utm = utmSource;
    final onboarded = hasSeenOnboarding;

    await _prefs.clear();

    await setLoggedIn(false);
    await setDarkMode(dark);
    if (fcm != null) await setFcmToken(fcm);
    if (utm != null) await setUtmSource(utm);
    if (onboarded) await setOnboardingSeen();
  }
}
