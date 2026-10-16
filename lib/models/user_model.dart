/// The customer, as `getDashboardData` returns them.
///
/// The CRM nests most of this under `Data.profile_details` and
/// `Data.customer_employment_details`, and omits whole groups until the
/// matching step is done — so every group is read defensively.
class UserModel {
  const UserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.pan,
    this.employerName,
    this.monthlyIncome,
    this.profilePicUrl,
    this.nextEvent,
    this.profileFilledPercent = 0,
    this.applicationFilledPercent = 0,
    this.isRegistered = false,
    this.isApplicationSubmitted = false,
    this.cibilScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = _group(json['profile_details']);
    final employment = _group(json['customer_employment_details']);
    final bureau = _group(json['bureau']);

    return UserModel(
      id: _text(json['cust_profile_id']) ?? _text(profile['id']) ?? '',
      mobile: _text(profile['mobile']) ?? _text(json['mobile']) ?? '',
      name: _fullName(profile),
      email: _text(profile['personal_email']),
      pan: _text(profile['pancard']),
      employerName: _text(employment['employer_name']),
      // The CRM sends income as a string.
      monthlyIncome: _number(
        profile['monthly_income'] ?? employment['monthly_income'],
      ),
      profilePicUrl: _text(json['profile_pic']),
      nextEvent: _text(json['next_event_name']),
      profileFilledPercent: _number(json['profile_filled_percent']) ?? 0,
      applicationFilledPercent:
          _number(json['application_filled_percent']) ?? 0,
      isRegistered: _flag(json['registration_successful']),
      isApplicationSubmitted: _flag(json['application_submitted']),
      cibilScore: _number(bureau['cibilScore']),
    );
  }

  final String id;
  final String mobile;
  final String? name;
  final String? email;
  final String? pan;
  final String? employerName;
  final int? monthlyIncome;

  /// Where the selfie ended up, once `selfie_upload` has been done.
  final String? profilePicUrl;

  /// The CRM's own `next_event_name` — what it wants done next.
  final String? nextEvent;

  /// How far the registration and the application each are, 0-100. The CRM
  /// computes both; the app does not have to.
  final int profileFilledPercent;
  final int applicationFilledPercent;

  final bool isRegistered;
  final bool isApplicationSubmitted;

  final int? cibilScore;

  String get initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);

    if (parts.isEmpty) return 'SB';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  bool get hasPhoto => (profilePicUrl ?? '').isNotEmpty;

  /// The percentage to show. Before registration completes the CRM tracks the
  /// profile; after it, the application. This is the rule the CRM itself uses.
  int get progressPercent =>
      isRegistered && nextEvent != 'register_now'
          ? applicationFilledPercent
          : profileFilledPercent;

  bool get isComplete => nextEvent == 'completed';

  // --- parsing helpers ----------------------------------------------------

  static Map<String, dynamic> _group(Object? value) =>
      value is Map ? value.cast<String, dynamic>() : const {};

  /// Trims, and treats an empty or "null" string as absent — the CRM sends
  /// both for fields the customer has not filled in.
  static String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  /// Numbers arrive as ints, doubles or strings depending on the field.
  static int? _number(Object? value) {
    if (value is num) return value.toInt();
    final text = _text(value);
    if (text == null) return null;
    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  /// Flags arrive as `1`, `"1"` or `true`.
  static bool _flag(Object? value) {
    final text = _text(value)?.toLowerCase();
    return text == '1' || text == 'true';
  }

  static String? _fullName(Map<String, dynamic> profile) {
    final parts = [
      _text(profile['first_name']),
      _text(profile['middle_name']),
      _text(profile['last_name']),
    ].whereType<String>();

    return parts.isEmpty ? null : parts.join(' ');
  }
}
