import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Dio client configuration for network requests
class DioClient {
  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  DioClient() {
    _dio = Dio();
    _configureDio();
  }

  /// Configure Dio with interceptors and options
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(_createConnectivityInterceptor());
  }

  /// Create logging interceptor for debugging
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) {
        // In production, you might want to use a proper logging library
        print('[DIO] $object');
      },
    );
  }

  /// Create error handling interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: exception,
          type: error.type,
          response: error.response,
        ));
      },
    );
  }

  /// Create connectivity checking interceptor
  Interceptor _createConnectivityInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          handler.reject(DioException(
            requestOptions: options,
            error: const NetworkException(
              message: 'No internet connection available',
              code: 0,
            ),
            type: DioExceptionType.connectionError,
          ));
          return;
        }
        handler.next(options);
      },
    );
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message: 'Request timeout. Please try again.',
          code: 408,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Connection error. Please check your internet connection.',
          code: 0,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled',
          code: 0,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Unknown error occurred: ${error.message}',
          code: 0,
        );

      default:
        return const NetworkException(
          message: 'An unexpected error occurred',
          code: 0,
        );
    }
  }

  /// Handle HTTP response errors
  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerException(
        message: 'No response from server',
        code: 0,
      );
    }

    final statusCode = response.statusCode ?? 0;
    final message = _getErrorMessage(response.data) ?? 'Server error occurred';

    switch (statusCode) {
      case 400:
        return ValidationException(message: message, code: statusCode);
      case 401:
        return AuthException(message: message, code: statusCode);
      case 403:
        return AuthException(message: 'Access forbidden', code: statusCode);
      case 404:
        return ServerException(message: 'Resource not found', code: statusCode);
      case 422:
        return ValidationException(message: message, code: statusCode);
      case 500:
        return ServerException(message: 'Internal server error', code: statusCode);
      case 502:
        return ServerException(message: 'Bad gateway', code: statusCode);
      case 503:
        return ServerException(message: 'Service unavailable', code: statusCode);
      default:
        return ServerException(message: message, code: statusCode);
    }
  }

  /// Extract error message from response data
  String? _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['detail'];
    }
    return data?.toString();
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }
}
