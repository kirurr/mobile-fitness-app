import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage.dart';
import '../auth/service.dart';
import '../auth/model.dart';

/// Function to get the backend URL from environment variables
Future<String> getBackendUrl() async {
  await dotenv.load(); // Load the .env file
  var backendUrl = dotenv.env['BACKEND_URL'];
  if (backendUrl == null || backendUrl.isEmpty) {
    throw Exception("BACKEND_URL is not defined in .env file");
  }
  return backendUrl;
}

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage = SecureStorageService();
  final AuthService _authService = AuthService();
  final Dio _dioForRetry = Dio(); // Temporary Dio instance for retries
  bool _isRefreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if the error is a 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Check if this is a request to the signin endpoint
      if (err.requestOptions.path.contains('/auth/signin')) {
        // If there's a 401 on signin, log the user out
        await _authService.signout();
        handler.next(err);
        return;
      }

      // Prevent multiple simultaneous refresh attempts
      if (_isRefreshing) {
        // Wait until the token refresh is complete
        while (_isRefreshing) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // Get the fresh token and update the request headers before retrying
        String? freshToken = await _storage.getToken();
        if (freshToken == null || freshToken.isEmpty) {
          handler.next(err);
          return;
        }
        err.requestOptions.headers['Authorization'] = 'Bearer $freshToken';

        // Retry the request with the new token
        try {
          final options = err.requestOptions;
          var response = await _dioForRetry.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          handler.next(err);
          return;
        }
      }

      _isRefreshing = true;

      try {
        // Get stored credentials
        String? email = await _storage.getEmail();
        String? password = await _storage.getPassword();

        if (email != null && password != null) {
          // Attempt to re-authenticate
          var result = await _authService.signin(
            SignInDTO(email: email, password: password),
          );

          if (result.error != null) {
            // If re-auth fails, sign out the user
            await _authService.signout();
            _isRefreshing = false;
            handler.next(err);
            return;
          }

          // Get the fresh token after successful re-authentication and update headers
          String? newToken = await _storage.getToken();

          // Update the headers with the new token
          if (newToken == null || newToken.isEmpty) {
            await _authService.signout();
            _isRefreshing = false;
            handler.next(err);
            return;
          }
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          var newOptions = err.requestOptions;
          newOptions.headers['Authorization'] = 'Bearer $newToken';
          // Retry the original request using the updated token
          var response = await _dioForRetry.fetch(newOptions);

          _isRefreshing = false;
          handler.resolve(response);
        } else {
          // No stored credentials, sign out the user
          await _authService.signout();
          _isRefreshing = false;
          handler.next(err);
        }
      } catch (e) {
        print('Error during token refresh: $e');
        // If anything goes wrong during re-auth, sign out the user
        await _authService.signout();
        _isRefreshing = false;
        handler.next(err);
      }
    } else {
      // For non-401 errors, continue as normal
      handler.next(err);
    }
  }
}

class ApiClient {
  late Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient._internal();

  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  /// Initialize the Dio instance with base options and interceptors
  Future<void> init() async {
    String baseUrl = await getBackendUrl();

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );

    _dio = Dio(options);

    // Add interceptors - put AuthInterceptor before LogInterceptor for proper order
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  /// Getter for the Dio instance
  Dio get dio => _dio;

  /// Helper method to get the auth token
  Future<String?> _getAuthToken() async {
    return await _storage.getToken();
  }

  /// Add auth token to headers
  Future<Map<String, dynamic>> _getAuthHeaders() async {
    String? token = await _getAuthToken();
    Map<String, dynamic> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Authenticated GET request
  Future<Response> getAuth(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Options options = Options(headers: await _getAuthHeaders());
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Authenticated POST request
  Future<Response> postAuth(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    Options options = Options(headers: await _getAuthHeaders());
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Authenticated PUT request
  Future<Response> putAuth(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    Options options = Options(headers: await _getAuthHeaders());
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Authenticated DELETE request
  Future<Response> deleteAuth(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    Options options = Options(headers: await _getAuthHeaders());
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

class ApiError {
  final String message;
  final int? code;

  ApiError({required this.message, this.code});
}

class ApiResult<T> {
  final T? data;
  final ApiError? error;

  ApiResult({this.data, this.error});
}

Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return ApiResult<T>(data: result);
  } on DioException catch (dioException) {
    print(dioException);
    return ApiResult<T>(
      error: ApiError(
        message: dioException.message ?? 'Unexpected error',
        code: dioException.response?.statusCode,
      ),
    );
  } catch (e) {
    return ApiResult<T>(error: ApiError(message: e.toString()));
  }
}
