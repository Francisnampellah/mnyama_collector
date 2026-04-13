import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _forestGreen = Color(0xFF1A3D2B);
const _forestGreenLight = Color(0xFF2D6647);
const _forestGreenMuted = Color(0xFF7AAB8A);
const _warmBg = Color(0xFFF7F5F0);
const _cardBg = Color(0xFFFFFFFF);
const _borderColor = Color(0xFFE0DDD8);
const _textPrimary = Color(0xFF1C1C1E);
const _textMuted = Color(0xFFA09D98);
const _labelColor = Color(0xFF8A8880);
const _redSurface = Color(0xFFFCEBEB);
const _redAccent = Color(0xFFA32D2D);
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  const LoginScreen({super.key, required this.onSwitchToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  late final AnimationController _fadeController;
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _itemCount = 4; // error, email, password, button

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnims = List.generate(_itemCount, (i) {
      final start = (i * 0.15).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_itemCount, (i) {
      final start = (i * 0.15).clamp(0.0, 1.0);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  Future<void> _handleLogin() async {
    context.read<AuthProvider>().clearError();
    final success = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'),
          backgroundColor: _forestGreenLight,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _warmBg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Green header ──────────────────────────────────────────
                  Container(
                    color: _forestGreen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.fromLTRB(24, topPad + 36, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand mark
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFFA8D4B8),
                                      size: 24,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Mnyama collect',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 20,
                                          color: const Color(0xFFE8F0EB),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        'ANIMAL DISEASE AI',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: _forestGreenMuted,
                                          letterSpacing: 1.8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Title
                              Text(
                                'Welcome back',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFE8F0EB),
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in to continue to your account',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _forestGreenMuted,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                        // Curved bottom edge
                        Container(
                          height: 26,
                          decoration: const BoxDecoration(
                            color: _warmBg,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(26),
                              topRight: Radius.circular(26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Form ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error banner
                        if (authProvider.error != null)
                          _animated(
                            0,
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ErrorBanner(
                                  message: authProvider.error!),
                            ),
                          ),

                        // Email
                        _animated(
                          1,
                          _AuthField(
                            label: 'Email address',
                            hint: 'your.email@example.com',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            enabled: !authProvider.isLoading,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        _animated(
                          2,
                          _AuthPasswordField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            obscured: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            enabled: !authProvider.isLoading,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login button
                        _animated(
                          3,
                          _AuthButton(
                            label: 'Sign in',
                            isLoading: authProvider.isLoading,
                            onTap: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Switch
                        _animated(
                          3,
                          _SwitchPrompt(
                            question: "Don't have an account?",
                            actionLabel: 'Register here',
                            onTap: widget.onSwitchToRegister,
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

// ─── Shared auth components ───────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.enabled,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _labelColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: _textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: _fieldDecoration(hint: hint, prefixIcon: icon),
        ),
      ],
    );
  }
}

class _AuthPasswordField extends StatelessWidget {
  const _AuthPasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscured,
    required this.onToggle,
    required this.enabled,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _labelColor,
            letterSpacing: 0.6,
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
          decoration: _fieldDecoration(
            hint: hint,
            prefixIcon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: _labelColor,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration({
  required String hint,
  required IconData prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(prefixIcon, size: 18, color: _labelColor),
    suffixIcon: suffix,
    filled: true,
    fillColor: _cardBg,
    hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
  );
}

class _AuthButton extends StatefulWidget {
  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          if (!widget.isLoading) widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: _forestGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFA8D4B8),
                      ),
                    ),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE8F0EB),
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SwitchPrompt extends StatelessWidget {
  const _SwitchPrompt({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$question  ',
          style: const TextStyle(
            fontSize: 13,
            color: _labelColor,
            letterSpacing: 0.1,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'Register here',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _forestGreen,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _redSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _redAccent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: _redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 13, color: _redAccent, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}