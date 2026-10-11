import 'package:dio/dio.dart';

import '../utils/app_strings.dart';
import 'api/api_endpoints.dart';
import 'api/api_result.dart';
import 'storage_service.dart';

/// Single Dio client for the app. Attaches the auth token and turns every
/// failure into an [ApiResult] so callers never have to catch DioException.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      // Let non-2xx responses through so we can read the server's message.
      validateStatus: (status) => status != null && status < 500,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => _dio.post(path, data: body));

  Future<ApiResult<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => _dio.put(path, data: body));

  Future<ApiResult<Map<String, dynamic>>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final status = response.statusCode ?? 0;
      final data = response.data;

      if (status >= 200 && status < 300) {
        return ApiResult.success(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      }

      return ApiResult.failure(
        _messageFrom(data) ?? AppStrings.somethingWentWrong,
        statusCode: status,
      );
    } on DioException catch (e) {
      return ApiResult.failure(_describe(e), statusCode: e.response?.statusCode);
    } catch (_) {
      return const ApiResult.failure(AppStrings.somethingWentWrong);
    }
  }

  /// Backends vary; look for the usual message keys before giving up.
  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    for (final key in ['message', 'error', 'detail', 'msg']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
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
        return _messageFrom(e.response?.data) ?? AppStrings.somethingWentWrong;
    }
  }
}
