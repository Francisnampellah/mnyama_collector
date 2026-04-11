import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If user is authenticated, show home screen
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return const HomeScreen();
        }

        // Show login or register screen
        if (_showLogin) {
          return LoginScreen(
            onSwitchToRegister: () {
              setState(() {
                _showLogin = false;
              });
            },
          );
        } else {
          return RegisterScreen(
            onSwitchToLogin: () {
              setState(() {
                _showLogin = true;
              });
            },
          );
        }
      },
    );
  }
}
