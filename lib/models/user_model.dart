/// Where the borrower is in the application journey.
enum KycStage { mobileVerified, personalDetails, panVerified, aadhaarVerified, bankLinked, complete }

class UserModel {
  const UserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.pan,
    this.employerName,
    this.monthlyIncome,
    this.creditLimit = 0,
    this.stage = KycStage.mobileVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: '${json['id'] ?? ''}',
        mobile: '${json['mobile'] ?? ''}',
        name: json['name'] as String?,
        email: json['email'] as String?,
        pan: json['pan'] as String?,
        employerName: json['employer_name'] as String?,
        monthlyIncome: (json['monthly_income'] as num?)?.toInt(),
        creditLimit: (json['credit_limit'] as num?)?.toInt() ?? 0,
        stage: _stageFrom(json['kyc_stage'] as String?),
      );

  final String id;
  final String mobile;
  final String? name;
  final String? email;
  final String? pan;
  final String? employerName;
  final int? monthlyIncome;

  /// Pre-approved limit in rupees. 0 means not assessed yet.
  final int creditLimit;
  final KycStage stage;

  String get initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SB';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  bool get isKycComplete => stage == KycStage.complete;

  static KycStage _stageFrom(String? raw) => switch (raw) {
        'personal_details' => KycStage.personalDetails,
        'pan_verified' => KycStage.panVerified,
        'aadhaar_verified' => KycStage.aadhaarVerified,
        'bank_linked' => KycStage.bankLinked,
        'complete' => KycStage.complete,
        _ => KycStage.mobileVerified,
      };
}
