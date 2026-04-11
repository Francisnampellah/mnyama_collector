import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// ─── Design tokens (matching new design language) ────────────────────────────
const _forestGreen = Color(0xFF1A3D2B);
const _forestGreenLight = Color(0xFF2D6647);
const _forestGreenMuted = Color(0xFF7AAB8A);
const _forestGreenSurface = Color(0xFFEAF3EC);

const _warmBg = Color(0xFFF7F5F0);
const _cardBg = Color(0xFFFFFFFF);
const _borderColor = Color(0xFFE0DDD8);

const _textPrimary = Color(0xFF1C1C1E);
const _textMuted = Color(0xFFA09D98);
const _labelColor = Color(0xFF8A8880);

const _redSurface = Color(0xFFFCEBEB);
const _redAccent = Color(0xFFA32D2D);
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterScreen({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (mounted) {
      context.read<AuthProvider>().clearError();
    }

    final success = await context.read<AuthProvider>().register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _warmBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    color: _forestGreen,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(24, topPad + 32, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _forestGreenLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.person_add_outlined,
                                  color: Color(0xFFA8D4B8),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE8F0EB),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Join NeTy to report disease cases',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE8F0EB).withOpacity(0.8),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        // Curved bottom
                        Container(
                          height: 24,
                          decoration: const BoxDecoration(
                            color: _warmBg,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error banner
                        if (authProvider.error != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _redSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _redAccent.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: _redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _redAccent,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Full Name field
                        _NeTyTextField(
                          label: 'Full name',
                          hint: 'John Doe',
                          icon: Icons.person_outline,
                          controller: _fullNameController,
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 14),

                        // Email field
                        _NeTyTextField(
                          label: 'Email address',
                          hint: 'your.email@example.com',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        _NeTyPasswordField(
                          label: 'Password',
                          hint: 'At least 6 characters',
                          controller: _passwordController,
                          obscured: _obscurePassword,
                          onToggle: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password field
                        _NeTyPasswordField(
                          label: 'Confirm password',
                          controller: _confirmPasswordController,
                          obscured: _obscureConfirmPassword,
                          onToggle: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                          enabled: !authProvider.isLoading,
                        ),
                        const SizedBox(height: 28),

                        // Register button
                        Container(
                          decoration: BoxDecoration(
                            color: _forestGreen,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _forestGreen.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: authProvider.isLoading
                                  ? null
                                  : _handleRegister,
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFA8D4B8),
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE8F0EB),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Switch to login
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _labelColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.onSwitchToLogin,
                                child: const Text(
                                  'Login here',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _forestGreen,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
// ─── Text field component ─────────────────────────────────────────────────────

class _NeTyTextField extends StatelessWidget {
  const _NeTyTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.enabled,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: 14,
            color: _textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: _labelColor),
            filled: true,
            fillColor: _cardBg,
            hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _forestGreen, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Password field component ──────────────────────────────────────────────────

class _NeTyPasswordField extends StatelessWidget {
  const _NeTyPasswordField({
    required this.label,
    required this.controller,
    required this.obscured,
    required this.onToggle,
    required this.enabled,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggle;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscured,
          style: const TextStyle(
            fontSize: 14,
            color: _textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint ?? '••••••••',
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: _labelColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: _labelColor,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: _cardBg,
            hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _forestGreen, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
