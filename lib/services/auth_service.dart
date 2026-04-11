import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_models.dart';
import 'token_service.dart';

class AuthService {
  // Change this to your backend server URL
  static const String baseUrl = 'http://192.168.1.122:4000/api';

  // Register new user
  static Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data'] ?? data);

        // Save token
        await TokenService.saveToken(authResponse.token);

        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An error occurred during registration: $e');
    }
  }

  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data'] ?? data);

        // Save token
        await TokenService.saveToken(authResponse.token);

        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An error occurred during login: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      await TokenService.clearToken();
    } catch (e) {
      throw ApiException(message: 'An error occurred during logout: $e');
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      return await TokenService.isTokenValid();
    } catch (e) {
      return false;
    }
  }

  // Get authorization header with token
  static Future<Map<String, String>> getAuthHeaders() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw ApiException(message: 'No token found');
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      rethrow;
    }
  }
}
