import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  Future<void> register(String username, String email, String password) async {
    final user = User(username: username, email: email, password: password);
    final response = await _apiService.register(user);
    await _storage.write(key: 'auth_token', value: response.token);
  }

  Future<void> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);
    final response = await _apiService.login(request);
    await _storage.write(key: 'auth_token', value: response.token);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
