/// Outcome of one API call. Either [data] is set or [error] explains why not.
class ApiResult<T> {
  const ApiResult.success(this.data)
      : error = null,
        statusCode = 200;

  const ApiResult.failure(this.error, {this.statusCode})
      : data = null;

  final T? data;
  final String? error;
  final int? statusCode;

  bool get isSuccess => error == null;

  /// True when the server rejected the session and the user must log in again.
  bool get isUnauthorised => statusCode == 401 || statusCode == 403;
}
