import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserService {
  static const String _userKey = 'auth_user';

  /// Save user data to persistent storage
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      print('[UserService] User saved: ${user.email}');
    } catch (e) {
      print('[UserService] Error saving user: $e');
      rethrow;
    }
  }

  /// Retrieve user data from persistent storage
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        print('[UserService] No user found in storage');
        return null;
      }

      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userData);
      print('[UserService] User retrieved: ${user.email}');
      return user;
    } catch (e) {
      print('[UserService] Error retrieving user: $e');
      return null;
    }
  }

  /// Clear user data from persistent storage
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('[UserService] User data cleared');
    } catch (e) {
      print('[UserService] Error clearing user: $e');
      rethrow;
    }
  }

  /// Check if user exists in storage
  static Future<bool> userExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey);
    } catch (e) {
      print('[UserService] Error checking user existence: $e');
      return false;
    }
  }
}
