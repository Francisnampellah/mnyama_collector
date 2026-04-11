import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Save token to secure storage
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // Extract and save user ID from token
      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['sub'] ?? decodedToken['id'] ?? '';
      if (userId.isNotEmpty) {
        await prefs.setString(_userIdKey, userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve token from storage
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      rethrow;
    }
  }

  // Get user ID from token
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      rethrow;
    }
  }

  // Check if token is valid (not expired)
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Get token expiration
  static Future<DateTime?> getTokenExpiration() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      rethrow;
    }
  }

  // Clear token from storage
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      rethrow;
    }
  }
}
