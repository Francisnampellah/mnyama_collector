import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

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
      _isAuthenticated = await AuthService.isAuthenticated();
      _token = await TokenService.getToken();
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
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
      // Validation
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        _error = 'All fields are required';
        notifyListeners();
        return false;
      }

      if (password != confirmPassword) {
        _error = 'Passwords do not match';
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        notifyListeners();
        return false;
      }

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
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validation
      if (email.isEmpty || password.isEmpty) {
        _error = 'Email and password are required';
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        notifyListeners();
        return false;
      }

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
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
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

      _user = null;
      _token = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
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
