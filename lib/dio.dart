import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Function to get the backend URL from environment variables
Future<String> getBackendUrl() async {
  await dotenv.load(); // Load the .env file
  var backendUrl = dotenv.env['BACKEND_URL'];
  if (backendUrl == null || backendUrl.isEmpty) {
    throw Exception("BACKEND_URL is not defined in .env file");
  }
  return backendUrl;
}

class ApiClient {
  late Dio _dio;

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
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(options);

    // Add interceptors if needed
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }

  /// Getter for the Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE request
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

// Example usage function (for demonstration purposes)
Future<void> exampleUsage() async {
  // Initialize the API client
  await ApiClient.instance.init();

  // Example API calls
  // var response = await ApiClient.instance.get('/users');
  // print(response.data);
}
