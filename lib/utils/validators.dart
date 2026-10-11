import 'app_strings.dart';

/// Form validators. Returning null means the field is valid.
class Validators {
  Validators._();

  static String? mobile(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return AppStrings.invalidMobile;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(input)) {
      return AppStrings.invalidMobile;
    }
    return null;
  }

  /// The CRM issues 4-digit OTPs; pass [length] for anything else.
  static String? otp(String? value, {int length = 4}) {
    final input = (value ?? '').trim();
    if (input.length != length) return 'Enter the $length-digit OTP';
    if (!RegExp(r'^\d+$').hasMatch(input)) return 'Enter the $length-digit OTP';
    return null;
  }

  static String? pan(String? value) {
    final input = (value ?? '').trim().toUpperCase();
    if (input.isEmpty) return 'PAN is required';
    if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(input)) {
      return 'Enter a valid PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  static String? aadhaar(String? value) {
    final input = (value ?? '').replaceAll(' ', '');
    if (input.isEmpty) return 'Aadhaar is required';
    if (!RegExp(r'^\d{12}$').hasMatch(input)) {
      return 'Enter a valid 12-digit Aadhaar';
    }
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(input)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
