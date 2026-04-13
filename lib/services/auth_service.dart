import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/auth_models.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class AuthService {
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

      final uri = Uri.parse('${AppConfig.backendBaseUrl}/auth/register');
      final body = jsonEncode(request.toJson());

      developer.log('🔐 REGISTRATION REQUEST STARTED', name: 'AuthService');
      developer.log('URL: $uri', name: 'AuthService');
      developer.log('Body: $body', name: 'AuthService');

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              developer.log(
                '⏱️ TIMEOUT: Request took longer than 10 seconds',
                name: 'AuthService',
              );
              return throw ApiException(
                message: 'Request timeout. Please try again.',
                statusCode: 408,
              );
            },
          );

      developer.log(
        '📊 Response Status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log('📄 Response Body: ${response.body}', name: 'AuthService');
      developer.log(
        '📋 Response Headers: ${response.headers}',
        name: 'AuthService',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data'] ?? data);

        developer.log('✅ REGISTRATION SUCCESS', name: 'AuthService');
        // Save token
        await TokenService.saveToken(authResponse.token);

        return authResponse;
      } else {
        developer.log(
          '❌ REGISTRATION FAILED - Status: ${response.statusCode}',
          name: 'AuthService',
        );
        final errorData = jsonDecode(response.body);
        developer.log('Error Details: $errorData', name: 'AuthService');
        throw ApiException(
          message: errorData['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException catch (e) {
      developer.log('🔴 API Exception: ${e.message}', name: 'AuthService');
      rethrow;
    } catch (e) {
      developer.log('🔴 Unexpected Error: $e', name: 'AuthService');
      developer.log('Stack trace: ${StackTrace.current}', name: 'AuthService');
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

      final uri = Uri.parse('${AppConfig.backendBaseUrl}/auth/login');
      final body = jsonEncode(request.toJson());

      developer.log('🔐 LOGIN REQUEST STARTED', name: 'AuthService');
      developer.log('URL: $uri', name: 'AuthService');
      developer.log('Email: $email', name: 'AuthService');

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              developer.log(
                '⏱️ TIMEOUT: Request took longer than 10 seconds',
                name: 'AuthService',
              );
              return throw ApiException(
                message: 'Request timeout. Please try again.',
                statusCode: 408,
              );
            },
          );

      developer.log(
        '📊 Response Status: ${response.statusCode}',
        name: 'AuthService',
      );
      developer.log('📄 Response Body: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data'] ?? data);

        developer.log('✅ LOGIN SUCCESS', name: 'AuthService');
        // Save token
        await TokenService.saveToken(authResponse.token);

        return authResponse;
      } else {
        developer.log(
          '❌ LOGIN FAILED - Status: ${response.statusCode}',
          name: 'AuthService',
        );
        final errorData = jsonDecode(response.body);
        developer.log('Error Details: $errorData', name: 'AuthService');
        throw ApiException(
          message: errorData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException catch (e) {
      developer.log('🔴 API Exception: ${e.message}', name: 'AuthService');
      rethrow;
    } catch (e) {
      developer.log('🔴 Unexpected Error: $e', name: 'AuthService');
      developer.log('Stack trace: ${StackTrace.current}', name: 'AuthService');
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
