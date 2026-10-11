/// What the CRM's `Status` field means.
enum CrmStatus {
  /// `1` — the call succeeded.
  ok,

  /// `3` — the customer should be bounced back to the dashboard.
  bounceToDashboard,

  /// `4` — the session is over; log the customer out.
  logout,

  /// Anything else, including a missing or unparseable status.
  failed;

  static CrmStatus parse(dynamic raw) => switch (raw.toString()) {
        '1' => CrmStatus.ok,
        '3' => CrmStatus.bounceToDashboard,
        '4' => CrmStatus.logout,
        _ => CrmStatus.failed,
      };
}

/// Outcome of one API call.
///
/// The CRM answers with HTTP 200 almost always and reports the real outcome in
/// the body: `Status` (see [CrmStatus]), `Message` and `Data`. So a 200 is not
/// success on its own — check [isSuccess].
class ApiResult<T> {
  const ApiResult.success(this.data, {this.message})
      : error = null,
        statusCode = 200,
        status = CrmStatus.ok;

  const ApiResult.failure(
    this.error, {
    this.statusCode,
    this.status = CrmStatus.failed,
  })  : data = null,
        message = null;

  /// The response's `Data` payload.
  final T? data;

  /// The CRM's `Message`, which is written for the customer.
  final String? message;

  final String? error;
  final int? statusCode;
  final CrmStatus status;

  bool get isSuccess => error == null;

  /// The CRM wants the customer sent back to the dashboard.
  bool get shouldBounceToDashboard => status == CrmStatus.bounceToDashboard;

  /// The CRM has ended the session.
  bool get shouldLogout => status == CrmStatus.logout || statusCode == 401;

  /// True when the CRM answered and refused, as opposed to the request never
  /// getting an answer. [message]/[error] is then written for the customer and
  /// safe to show; a transport failure's text is not.
  bool get isCrmRefusal => !isSuccess && status != CrmStatus.failed;

  /// True when the call never reached a verdict: no network, a timeout, a
  /// non-JSON body, or a 5xx. Worth offering a retry for.
  bool get isTransportFailure => !isSuccess && status == CrmStatus.failed;

  /// The CRM told us where to send the customer, so the caller should navigate
  /// rather than show an error.
  bool get requiresRedirect => shouldLogout || shouldBounceToDashboard;
}
