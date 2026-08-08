import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/application/auth_state.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

/// Highly aesthetic Login & Registration screen matching Aura AI mocks.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _serverHostController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _serverHostController.text = settings.serverHost;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _serverHostController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You must agree to the Terms of Service & Privacy Policy.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authStateProvider.notifier);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    // Save server host configuration dynamically
    await settingsNotifier.setServerHost(_serverHostController.text.trim());

    bool success;
    if (_isLogin) {
      success = await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authNotifier.register(
        username: _usernameController.text.trim().toLowerCase(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success) {
        setState(() {
          _isLogin = true;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (!success && mounted) {
      final error = ref.read(authStateProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showServerConfigDialog() async {
    _serverHostController.text =
        'https://be10-2001-ee0-1b38-2b4c-2838-129a-ce08-7508.ngrok-free.app/api/v1';
    unawaited(
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Configure Server Host'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the backend base URL (e.g. http://10.0.2.2:8080/api/v1):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _serverHostController,
                decoration: const InputDecoration(
                  hintText: 'http://10.0.2.2:8080/api/v1',
                  prefixIcon: Icon(Icons.dns_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(settingsProvider.notifier)
                    .setServerHost(_serverHostController.text.trim());
                if (!context.mounted) return;
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Calculate password strength segments (1 to 4)
  int _calculatePasswordStrength(String pass) {
    if (pass.isEmpty) return 0;
    var score = 0;
    if (pass.length >= 6) score++;
    if (pass.contains(RegExp('[A-Z]'))) score++;
    if (pass.contains(RegExp('[0-9]'))) score++;
    if (pass.contains(RegExp(r'[!@#$&*~]'))) score++;
    return score.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final strength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Icon(
                          Icons.spa,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ai Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.settings_outlined, color: Colors.grey),
                    onPressed: _showServerConfigDialog,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Welcome Back Heading
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? 'Sign in to continue your secure conversations.'
                            : 'Join the future of secure AI communication.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (!_isLogin) ...[
                        // FULL NAME (Registration Only)
                        const Text(
                          'FULL NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Full name required'
                              : null,
                        ),
                        const SizedBox(height: 18),

                        // USERNAME (Registration Only)
                        const Text(
                          'USERNAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Choose a unique username',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                              color: Colors.grey,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Username required';
                            }
                            if (val.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val)) {
                              return 'Only alphanumeric characters '
                                  '& underscores';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                      ],

                      // EMAIL ADDRESS
                      const Text(
                        'EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'name@company.com',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Invalid email address'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // PASSWORD
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _isLogin
                              ? '•••••••••'
                              : 'Create a strong password',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),

                      // Password Strength Indicator (Registration Only)
                      if (!_isLogin && _passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(4, (index) {
                            final filled = index < strength;
                            var color = Colors.grey.shade300;
                            if (filled) {
                              if (strength == 1) color = Colors.red;
                              if (strength == 2) color = Colors.orange;
                              if (strength == 3) color = Colors.yellow.shade700;
                              if (strength == 4) color = Colors.green;
                            }
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                      const SizedBox(height: 18),

                      if (!_isLogin) ...[
                        // CONFIRM PASSWORD (Registration Only)
                        const Text(
                          'CONFIRM PASSWORD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Repeat your password',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.refresh,
                              color: Colors.grey,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm password required';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Agree to Terms Checkbox (Registration Only)
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              activeColor: Colors.black,
                              onChanged: (val) =>
                                  setState(() => _agreeToTerms = val ?? false),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Forgot Password Link (Login Only)
                      if (_isLogin) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Main Login/Register Button
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin ? 'Log In' : 'Create Account',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Continue with divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Sign-in Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                    height: 18,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.g_mobiledata,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Apple',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Need an account footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account? "
                                : 'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'Register' : 'Log In',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
