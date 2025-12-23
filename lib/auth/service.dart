import 'package:mobile_fitness_app/auth/model.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/app/storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService();

  Future<ApiResult<AuthResponse>> signin(SignInDTO data) async {
    var res = await safeApiCall(
      () => _apiClient.post('/auth/signin', data: data.toJson()),
    );
    if (res.error != null) {
      return ApiResult(error: res.error);
    }

    var authResponse = AuthResponse.fromJson(res.data?.data);

    await _storage.storeToken(authResponse.token);
    await _storage.storeUserId(authResponse.userId.toString());
    await _storage.storeEmail(data.email);
    await _storage.storePassword(data.password);

    return ApiResult(data: authResponse);
  }

  Future<ApiResult<AuthResponse>> signup(SignUpDTO data) async {
    var res = await safeApiCall(
      () => _apiClient.post('/auth/signup', data: data.toJson()),
    );
    if (res.error != null) {
      return ApiResult(error: res.error);
    }

    var authResponse = AuthResponse.fromJson(res.data?.data);

    await _storage.storeToken(authResponse.token);
    await _storage.storeUserId(authResponse.userId.toString());
    await _storage.storeEmail(data.email);
    await _storage.storePassword(data.password);

    return ApiResult(data: authResponse);
  }

  Future<void> signout() async {
    await _storage.deleteToken();
    await _storage.deleteUserId();
    await _storage.deleteEmail();
    await _storage.deletePassword();
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
