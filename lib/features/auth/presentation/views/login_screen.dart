import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/auth/application/auth_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Highly aesthetic Login & Registration screen with full
/// AppLocalizations support.
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

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final strength = _calculatePasswordStrength(_passwordController.text);
    final authInk = AppColor.authInk.of(context);
    final muted = AppColor.inkMuted.of(context);
    final solidInk = AppColor.inkSolid.of(context);
    final dividerColor = AppColor.authDivider.of(context);

    return Scaffold(
      backgroundColor: AppColor.authBackground.of(context),
      body: SafeArea(
        child: ListView(
          padding: AppPadding.screenHorizontal,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppGap.vXxl,
                ClipRRect(
                  child: Image.asset(
                    'assets/icons/lotus_connect_logo.png',
                    height: AppSize.avatarXxl,
                    width: AppSize.avatarXxl,
                  ),
                ),
                Text(
                  loc?.appName ?? 'Lotus Connect',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: authInk,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppGap.vSm,
                      Text(
                        _isLogin
                            ? (loc?.signInSubtitle ??
                                'Sign in to continue your '
                                    'secure conversations.')
                            : (loc?.joinSubtitle ??
                                'Join the future of secure communication.'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: authInk,
                        ),
                      ),
                      AppGap.vXxxl,

                      if (!_isLogin) ...[
                        Text(
                          loc?.fullNameLabel ?? 'FULL NAME',
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: authInk,
                          ),
                        ),
                        AppGap.vSm,
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            hintText: loc?.enterFullNameHint ??
                                'Enter your full name',
                            hintStyle: theme.textTheme.labelMedium,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: muted,
                              size: AppSize.iconSm,
                            ),
                            filled: true,
                            border: const OutlineInputBorder(
                              borderRadius: AppRadius.input,
                              borderSide: AppBorder.none,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? (loc?.fullNameRequired ?? 'Full name required')
                              : null,
                        ),
                        AppGap.vLg,
                        Text(
                          loc?.usernameLabel ?? 'USERNAME',
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: authInk,
                          ),
                        ),
                        AppGap.vSm,
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: loc?.chooseUsernameHint ??
                                'Choose a unique username',
                            hintStyle: theme.textTheme.labelMedium,
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              color: muted,
                              size: AppSize.iconSm,
                            ),
                            filled: true,
                            border: const OutlineInputBorder(
                              borderRadius: AppRadius.input,
                              borderSide: AppBorder.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return loc?.usernameRequired ??
                                  'Username required';
                            }
                            if (val.length < 3) {
                              return loc?.usernameMinLength ??
                                  'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val)) {
                              return loc?.usernameAlphanumericOnly ??
                                  'Only alphanumeric characters & underscores';
                            }
                            return null;
                          },
                        ),
                        AppGap.vLg,
                      ],

                      Text(
                        loc?.emailAddressLabel ?? 'EMAIL ADDRESS',
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: authInk,
                        ),
                      ),
                      AppGap.vSm,
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: loc?.emailHint ?? 'name@company.com',
                          hintStyle: theme.textTheme.labelMedium,
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: muted,
                            size: AppSize.iconSm,
                          ),
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.input,
                            borderSide: AppBorder.none,
                          ),
                        ),
                        validator: (val) => val == null || !val.contains('@')
                            ? (loc?.invalidEmail ?? 'Invalid email address')
                            : null,
                      ),
                      AppGap.vLg,

                      Text(
                        loc?.passwordLabel ?? 'PASSWORD',
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: authInk,
                        ),
                      ),
                      AppGap.vSm,
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _isLogin
                              ? (loc?.loginPasswordHint ?? '•••••••••')
                              : (loc?.createPasswordHint ??
                                  'Create a strong password'),
                          hintStyle: theme.textTheme.labelMedium,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: muted,
                            size: AppSize.iconSm,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: muted,
                              size: AppSize.iconSm,
                            ),
                            tooltip: _obscurePassword
                                ? (loc?.showPassword ?? 'Show password')
                                : (loc?.hidePassword ?? 'Hide password'),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.input,
                            borderSide: AppBorder.none,
                          ),
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? (loc?.passwordMinLength ??
                                'Password must be at least 6 characters')
                            : null,
                      ),

                      // Password Strength Indicator (Registration Only)
                      if (!_isLogin && _passwordController.text.isNotEmpty) ...[
                        AppGap.vSm,
                        Semantics(
                          label: loc?.passwordStrength ?? 'Password strength',
                          value: '$strength / 4',
                          child: Row(
                            children: List.generate(4, (index) {
                              final filled = index < strength;
                              var color = AppColor.inkSubtle.of(context);
                              if (filled) {
                                if (strength == 1) {
                                  color = AppColor.danger.of(context);
                                }
                                if (strength == 2) {
                                  color = AppColor.orange.of(context);
                                }
                                if (strength == 3) {
                                  color = AppColor.warningYellow.of(context);
                                }
                                if (strength == 4) {
                                  color = AppColor.successGreen.of(context);
                                }
                              }
                              return Expanded(
                                child: Container(
                                  height: AppSize.progressBarHeight,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSize.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: AppRadius.full,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                      AppGap.vLg,

                      if (!_isLogin) ...[
                        Text(
                          loc?.confirmPasswordLabel ?? 'CONFIRM PASSWORD',
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: authInk,
                          ),
                        ),
                        AppGap.vSm,
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: loc?.repeatPasswordHint ??
                                'Repeat your password',
                            hintStyle: theme.textTheme.labelMedium,
                            prefixIcon: Icon(
                              Icons.refresh,
                              color: muted,
                              size: AppSize.iconSm,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: muted,
                                size: AppSize.iconSm,
                              ),
                              tooltip: _obscureConfirmPassword
                                  ? (loc?.showPassword ?? 'Show password')
                                  : (loc?.hidePassword ?? 'Hide password'),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                            filled: true,
                            border: const OutlineInputBorder(
                              borderRadius: AppRadius.input,
                              borderSide: AppBorder.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return loc?.confirmPasswordRequired ??
                                  'Confirm password required';
                            }
                            if (val != _passwordController.text) {
                              return loc?.passwordsDoNotMatch ??
                                  'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        AppGap.vLg,
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              activeColor: solidInk,
                              onChanged: (val) =>
                                  setState(() => _agreeToTerms = val ?? false),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: AppColor.inkMutedDark.of(context),
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: loc?.agreeToTermsPrefix ??
                                          'I agree to the ',
                                    ),
                                    TextSpan(
                                      text: loc?.termsOfService ??
                                          'Terms of Service',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: solidInk,
                                      ),
                                    ),
                                    TextSpan(
                                      text: loc?.andWord ?? ' and ',
                                    ),
                                    TextSpan(
                                      text: loc?.privacyPolicy ??
                                          'Privacy Policy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: solidInk,
                                      ),
                                    ),
                                    TextSpan(
                                      text: loc?.agreeToTermsSuffix ?? '.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppGap.vLg,
                      ],

                      if (_isLogin) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              loc?.forgotPassword ?? 'Forgot Password?',
                              style: TextStyle(
                                color: solidInk,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                      AppGap.vMd,

                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.authCtaBg.of(context),
                          foregroundColor: AppColor.authCtaFg.of(context),
                          padding: AppPadding.vLg,
                          shape: AppBorder.rounded(
                            radius: AppSize.radiusButton,
                          ),
                          elevation: AppSize.elevationNone,
                        ),
                        child: authState.isLoading
                            ? SizedBox(
                                height: AppSize.loaderSizeSm,
                                width: AppSize.loaderSizeSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSize.borderThick,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColor.authCtaFg.of(context),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? (loc?.logInButton ?? 'Log In')
                                        : (loc?.createAccountButton ??
                                            'Create Account'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  AppGap.hSm,
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: AppSize.iconSm,
                                  ),
                                ],
                              ),
                      ),
                      AppGap.vXxl,

                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: dividerColor),
                          ),
                          Padding(
                            padding: AppPadding.hLg,
                            child: Text(
                              loc?.orContinueWith ?? 'OR CONTINUE WITH',
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: authInk,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: dividerColor),
                          ),
                        ],
                      ),
                      AppGap.vXxl,

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: AppPadding.vMd,
                                side: AppBorder.thin(dividerColor),
                                shape: AppBorder.rounded(
                                  radius: AppSize.radiusButton,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/google-logo.jpg',
                                    height: AppSize.iconSm,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.g_mobiledata,
                                      color: AppColor.infoBlue.of(context),
                                      size: AppSize.iconMd,
                                    ),
                                  ),
                                  AppGap.hSm,
                                  Text(
                                    loc?.google ?? 'Google',
                                    style: TextStyle(
                                      color: solidInk,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppGap.hMd,
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: AppPadding.vMd,
                                side: AppBorder.thin(dividerColor),
                                shape: AppBorder.rounded(
                                  radius: AppSize.radiusButton,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    color: solidInk,
                                    size: AppSize.iconSm,
                                  ),
                                  AppGap.hSm,
                                  Text(
                                    loc?.apple ?? 'Apple',
                                    style: TextStyle(
                                      color: solidInk,
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
                      AppGap.vXxxl,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? (loc?.dontHaveAccount ??
                                    "Don't have an account? ")
                                : (loc?.alreadyHaveAccount ??
                                    'Already have an account? '),
                            style: TextStyle(
                              color: AppColor.inkMutedDark.of(context),
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
                              _isLogin
                                  ? (loc?.registerAction ?? 'Register')
                                  : (loc?.logInButton ?? 'Log In'),
                              style: TextStyle(
                                color: solidInk,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppGap.vXxxl,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.mustAgreeTerms ??
                'You must agree to the Terms of Service & Privacy Policy.',
          ),
          backgroundColor: AppColor.danger.of(context),
        ),
      );
      return;
    }

    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.passwordsDoNotMatch ?? 'Passwords do not match',
          ),
          backgroundColor: AppColor.danger.of(context),
        ),
      );
      return;
    }

    final authNotifier = ref.read(authStateProvider.notifier);

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
          SnackBar(
            content: Text(
              loc?.registrationSuccess ??
                  'Registration successful! Please login.',
            ),
            backgroundColor: AppColor.successGreen.of(context),
          ),
        );
      }
    }

    if (!success && mounted) {
      final error = ref.read(authStateProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ??
                (_isLogin
                    ? (loc?.failedToLogin ??
                        loc?.authenticationFailed ??
                        'Failed to log in')
                    : (loc?.failedToRegister ??
                        loc?.authenticationFailed ??
                        'Failed to register')),
          ),
          backgroundColor: AppColor.danger.of(context),
        ),
      );
    }
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
}
