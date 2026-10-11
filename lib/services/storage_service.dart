import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences. Call [init] once before runApp.
class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyMobile = 'mobile';
  static const String _keyOnboarded = 'onboarding_seen';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // auth token
  static String? get token => _prefs.getString(_keyToken);
  static Future<void> setToken(String value) =>
      _prefs.setString(_keyToken, value);

  static bool get isLoggedIn => (token ?? '').isNotEmpty;

  // user
  static String? get userId => _prefs.getString(_keyUserId);
  static Future<void> setUserId(String value) =>
      _prefs.setString(_keyUserId, value);

  static String? get mobile => _prefs.getString(_keyMobile);
  static Future<void> setMobile(String value) =>
      _prefs.setString(_keyMobile, value);

  // onboarding
  static bool get hasSeenOnboarding => _prefs.getBool(_keyOnboarded) ?? false;
  static Future<void> setOnboardingSeen() =>
      _prefs.setBool(_keyOnboarded, true);

  /// Wipes the session on logout. Keeps the onboarding flag.
  static Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyMobile);
  }
}
