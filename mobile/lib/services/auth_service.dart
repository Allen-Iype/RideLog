import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Base URL - change this for different environments
  // For Android emulator: use 10.0.2.2
  // For iOS simulator: use localhost
  // For physical device: use your computer's IP address
  static const String baseUrl = 'http://localhost:8080/api/v1';

  String? _cachedToken;
  User? _cachedUser;

  // Get current authentication token
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;

    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _cachedUser = User.fromJson(json.decode(userJson));
    }
    return _cachedUser;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Register new user
  Future<AuthResponse> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveAuthData(authResponse);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Login user
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveAuthData(authResponse);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    _cachedToken = null;
    _cachedUser = null;
  }

  // Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storage.write(key: _tokenKey, value: authResponse.token);
    await _storage.write(
        key: _userKey, value: json.encode(authResponse.user.toJson()));
    _cachedToken = authResponse.token;
    _cachedUser = authResponse.user;
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedUser = null;
  }
}
