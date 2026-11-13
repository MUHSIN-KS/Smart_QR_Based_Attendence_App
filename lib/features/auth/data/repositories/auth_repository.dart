import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      await _storageService.saveUser(user.toJson());
      return user;
    }

    throw Exception('Invalid server response format during login');
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'employee',
    String department = 'Operations',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
        'department': department,
      },
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      await _storageService.saveUser(user.toJson());
      return user;
    }

    throw Exception('Invalid server response format during registration');
  }

  Future<UserModel?> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    if (response is Map<String, dynamic> && response['data'] != null) {
      final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
      await _storageService.saveUser(user.toJson());
      return user;
    }
    return null;
  }

  UserModel? getCachedUser() {
    final cached = _storageService.getUser();
    if (cached != null) {
      return UserModel.fromJson(cached);
    }
    return null;
  }

  String? getCachedToken() {
    return _storageService.getToken();
  }

  Future<void> logout() async {
    await _storageService.clearSession();
  }
}

