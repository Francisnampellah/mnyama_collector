import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Constructor - check if already authenticated
  AuthProvider() {
    _checkAuthStatus();
  }

  // Check if user is already authenticated on app startup
  Future<void> _checkAuthStatus() async {
    try {
      print('[AuthProvider] Checking authentication status...');

      // Check if token exists and is valid
      final token = await TokenService.getToken();
      final isTokenValid = await TokenService.isTokenValid();

      if (token != null && isTokenValid) {
        print('[AuthProvider] Valid token found, restoring user session...');

        // Try to restore user data from storage
        final user = await UserService.getUser();

        if (user != null) {
          _user = user;
          _token = token;
          _isAuthenticated = true;
          print('[AuthProvider] User session restored: ${user.email}');
        } else {
          print('[AuthProvider] Token valid but no user data found');
          _isAuthenticated = false;
          _token = null;
        }
      } else {
        print('[AuthProvider] No valid token found');
        _isAuthenticated = false;
        _token = null;
      }

      notifyListeners();
    } catch (e) {
      print('[AuthProvider] Error checking auth status: $e');
      _isAuthenticated = false;
      _token = null;
      _user = null;
    }
  }

  // Register new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      developer.log(
        '📝 REGISTER: Starting registration for email: $email',
        name: 'AuthProvider',
      );

      // Validation
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        _error = 'All fields are required';
        developer.log(
          '❌ REGISTER: Validation failed - empty fields',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      if (password != confirmPassword) {
        _error = 'Passwords do not match';
        developer.log(
          '❌ REGISTER: Validation failed - passwords do not match',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        developer.log(
          '❌ REGISTER: Validation failed - password too short',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        developer.log(
          '❌ REGISTER: Validation failed - invalid email format',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      developer.log(
        '✓ REGISTER: Validation passed, calling AuthService',
        name: 'AuthProvider',
      );

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      _user = response.user;
      _token = response.token;
      _isAuthenticated = true;
      _isLoading = false;
      _error = null;

      // Save user data for persistence
      await UserService.saveUser(response.user);
      developer.log(
        '✅ REGISTER: User registered and saved: ${response.user.email}',
        name: 'AuthProvider',
      );

      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      developer.log(
        '🔴 REGISTER API ERROR: ${e.message} (Status: ${e.statusCode})',
        name: 'AuthProvider',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      developer.log('🔴 REGISTER ERROR: $e', name: 'AuthProvider');
      developer.log('Stack trace: ${StackTrace.current}', name: 'AuthProvider');
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      developer.log(
        '🔐 LOGIN: Starting login for email: $email',
        name: 'AuthProvider',
      );

      // Validation
      if (email.isEmpty || password.isEmpty) {
        _error = 'Email and password are required';
        developer.log(
          '❌ LOGIN: Validation failed - empty fields',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        developer.log(
          '❌ LOGIN: Validation failed - invalid email format',
          name: 'AuthProvider',
        );
        notifyListeners();
        return false;
      }

      developer.log(
        '✓ LOGIN: Validation passed, calling AuthService',
        name: 'AuthProvider',
      );

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await AuthService.login(
        email: email,
        password: password,
      );

      _user = response.user;
      _token = response.token;
      _isAuthenticated = true;
      _isLoading = false;
      _error = null;

      // Save user data for persistence
      await UserService.saveUser(response.user);
      developer.log(
        '✅ LOGIN: User logged in and saved: ${response.user.email}',
        name: 'AuthProvider',
      );

      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      developer.log(
        '🔴 LOGIN API ERROR: ${e.message} (Status: ${e.statusCode})',
        name: 'AuthProvider',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      developer.log('🔴 LOGIN ERROR: $e', name: 'AuthProvider');
      developer.log('Stack trace: ${StackTrace.current}', name: 'AuthProvider');
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await AuthService.logout();

      // Clear both token and user data
      await UserService.clearUser();
      await TokenService.clearToken();

      _user = null;
      _token = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;

      print('[AuthProvider] User logged out and data cleared');
      notifyListeners();
    } catch (e) {
      _error = 'Error during logout: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
