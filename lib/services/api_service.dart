import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_strings.dart';
import 'api/api_config.dart';
import 'api/api_result.dart';
import 'storage_service.dart';

/// Which auth header a call carries.
///
/// Which endpoint takes which is **not** a clean pre-login / post-login split
/// — the CRM's assignment is irregular, so copy it per endpoint from the
/// reference app rather than inferring it:
///
/// | Endpoint | Mode |
/// |---|---|
/// | login, resend_otp, otp_verify | [login] |
/// | verifyRazorPayCheckPaymentStatus | [login] |
/// | checkInstantAppVersion | [login] |
/// | fetchOkycData | [login] |
/// | getOkycOtp | [static_] |
/// | feedback | [static_] |
/// | everything else | [token] |
enum AuthMode {
  /// The platform-dependent `Auth` key (`apiHeader1` in the reference app).
  /// Despite the name, some post-login endpoints use it too — see the table.
  login,

  /// The general static `Auth` key (`apiHeader` in the reference app).
  static_,

  /// The logged-in customer's `Authtoken`.
  token,
}

/// Single Dio client for the app.
///
/// The Salary Brother CRM is not a REST API:
///  * almost everything is a POST to one of two write endpoints, with
///    `event_name` in the body deciding what happens;
///  * auth travels in an `Auth` or `Authtoken` header, not `Authorization`;
///  * the outcome is in the body's `Status`, not the HTTP status.
///
/// Every failure comes back as an [ApiResult] so callers never catch
/// DioException.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      // Let non-2xx responses through so we can read the server's message.
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  /// Posts to [endpoint] under the platform prefix.
  ///
  /// [event] is the `event_name` discriminator; it is merged into [body] so
  /// callers cannot forget it.
  Future<ApiResult<Map<String, dynamic>>> post(
    String endpoint, {
    String? event,
    Map<String, dynamic>? body,
    AuthMode auth = AuthMode.token,
  }) =>
      _send(
        () => _dio.post(
          ApiConfig.url(endpoint),
          data: {
            if (event != null) 'event_name': event,
            ...?body,
          },
          options: _options(auth),
        ),
      );

  /// Posts to the Aadhaar OKYC module, which sits outside the platform prefix
  /// and answers with its own `statusCode` / `data` envelope.
  ///
  /// The two OKYC calls disagree on which key they want, so [auth] has no
  /// default: `getOkycOtp` wants [AuthMode.static_] and `fetchOkycData` wants
  /// [AuthMode.login]. Pass it explicitly.
  ///
  /// [requireOtpSent] additionally demands `data.otpSentStatus == "true"`,
  /// which `getOkycOtp` returns alongside a 200 even when no OTP went out.
  Future<ApiResult<Map<String, dynamic>>> postOkyc(
    String endpoint, {
    required AuthMode auth,
    Map<String, dynamic>? body,
    bool requireOtpSent = false,
  }) =>
      _send(
        () => _dio.post(
          ApiConfig.unprefixedUrl(endpoint),
          data: body,
          options: _options(auth),
        ),
        okycEnvelope: true,
        requireOtpSent: requireOtpSent,
      );

  Options _options(AuthMode auth) {
    if (kDebugMode && ApiConfig.hasPlaceholderKeys) {
      debugPrint(
        'ApiService: ApiConfig auth keys are still placeholders — '
        'the CRM will reject this request.',
      );
    }

    final headers = switch (auth) {
      AuthMode.login => ApiConfig.loginHeaders,
      AuthMode.static_ => ApiConfig.staticHeaders,
      AuthMode.token => ApiConfig.tokenHeaders(StorageService.token ?? ''),
    };

    return Options(headers: headers, preserveHeaderCase: true);
  }

  Future<ApiResult<Map<String, dynamic>>> _send(
    Future<Response<dynamic>> Function() request, {
    bool okycEnvelope = false,
    bool requireOtpSent = false,
  }) async {
    try {
      final response = await request();
      final httpStatus = response.statusCode ?? 0;
      final raw = response.data;

      // A non-JSON body (an HTML error page, say) must not reach the callers.
      if (raw is! Map) {
        return ApiResult.failure(
          AppStrings.somethingWentWrong,
          statusCode: httpStatus,
        );
      }
      final map = Map<String, dynamic>.from(raw);

      return okycEnvelope
          ? _readOkyc(map, httpStatus, requireOtpSent: requireOtpSent)
          : _readCrm(map, httpStatus);
    } on DioException catch (e) {
      return ApiResult.failure(_describe(e), statusCode: e.response?.statusCode);
    } catch (_) {
      return const ApiResult.failure(AppStrings.somethingWentWrong);
    }
  }

  /// The standard envelope: `Status` 1 ok / 3 bounce / 4 logout, plus
  /// `Message` and `Data`.
  ApiResult<Map<String, dynamic>> _readCrm(
    Map<String, dynamic> body,
    int httpStatus,
  ) {
    final status = CrmStatus.parse(body['Status']);
    final message = body['Message']?.toString();
    final data = body['Data'];

    if (status == CrmStatus.ok) {
      return ApiResult.success(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
        message: message,
      );
    }

    return ApiResult.failure(
      (message?.trim().isNotEmpty ?? false)
          ? message!
          : AppStrings.somethingWentWrong,
      statusCode: httpStatus,
      status: status,
    );
  }

  /// The Aadhaar OKYC envelope: lowercase `statusCode` and `data`.
  ///
  /// Only `200` counts as success — the CRM's other codes do not — and
  /// `getOkycOtp` can answer 200 while reporting that no OTP was sent, so
  /// [requireOtpSent] checks that too.
  ApiResult<Map<String, dynamic>> _readOkyc(
    Map<String, dynamic> body,
    int httpStatus, {
    bool requireOtpSent = false,
  }) {
    final code = body['statusCode']?.toString();
    final message = (body['message'] ?? body['Message'])?.toString();
    final raw = body['data'];
    final data =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    final otpSent =
        !requireOtpSent || data['otpSentStatus']?.toString() == 'true';

    if (code == '200' && otpSent) {
      return ApiResult.success(data, message: message);
    }

    return ApiResult.failure(
      (message?.trim().isNotEmpty ?? false)
          ? message!
          : 'Could not send the Aadhaar OTP. Please try again.',
      statusCode: httpStatus,
    );
  }

  String _describe(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return AppStrings.noInternet;
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        final data = e.response?.data;
        if (data is Map) {
          final message = (data['Message'] ?? data['message'])?.toString();
          if (message != null && message.trim().isNotEmpty) return message;
        }
        return AppStrings.somethingWentWrong;
    }
  }
}
