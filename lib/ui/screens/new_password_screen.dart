import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'signin_screen.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/services/notification_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool hasUpperCase = false;
  bool hasSpecialChar = false;
  bool hasNumber = false;
  bool passwordsMatch = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  void _validatePassword(String password) {
    setState(() {
      passwordsMatch =
          password == _confirmPasswordController.text && password.isNotEmpty;
    });
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      passwordsMatch = confirmPassword == _passwordController.text &&
          confirmPassword.isNotEmpty;
    });
  }

  bool get isPasswordValid =>
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      passwordsMatch;

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      NotificationService.showValidationError(
        context,
        'Please enter your new password',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      NotificationService.showPasswordMismatch(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.resetPassword(
        widget.email,
        _passwordController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        NotificationService.showPasswordResetSuccess(
          context,
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (route) => false,
            );
          },
        );
      } else {
        NotificationService.showGenericError(
          context,
          response['error'] ?? 'Failed to reset password. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      NotificationService.showNetworkError(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(1, 18, 42, 1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: isIOS
            ? CupertinoNavigationBar(
                backgroundColor: Colors.transparent,
                border: null,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  ),
                ),
              )
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final paddingHorizontal = maxWidth * 0.05;
            final iconSize = maxWidth * 0.15;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: size.height * 0.02,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Icon(
                      isIOS ? CupertinoIcons.lock : Icons.lock_outline,
                      size: iconSize,
                      color: Colors.blue,
                    ),
                    SizedBox(height: size.height * 0.04),
                    _buildPasswordField(maxWidth, isIOS),
                    SizedBox(height: size.height * 0.02),
                    _buildConfirmPasswordField(maxWidth, isIOS),
                    SizedBox(height: size.height * 0.02),
                    _buildPasswordRequirements(maxWidth, isIOS),
                    SizedBox(height: size.height * 0.04),
                    _buildResetButton(maxWidth, isIOS),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(double maxWidth, bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: isIOS
          ? CupertinoTextField(
              controller: _passwordController,
              onChanged: _validatePassword,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              placeholder: 'New Password',
              placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  _obscurePassword
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            )
          : TextField(
              controller: _passwordController,
              onChanged: _validatePassword,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
    );
  }

  Widget _buildConfirmPasswordField(double maxWidth, bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: isIOS
          ? CupertinoTextField(
              controller: _confirmPasswordController,
              onChanged: _validateConfirmPassword,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscureConfirmPassword,
              placeholder: 'Rewrite New Password',
              placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  _obscureConfirmPassword
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            )
          : TextField(
              controller: _confirmPasswordController,
              onChanged: _validateConfirmPassword,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Rewrite New Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordRequirements(double maxWidth, bool isIOS) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIOS ? CupertinoIcons.info : Icons.info_outline,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Password must have:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement('One capital letter or more', hasUpperCase, isIOS),
          _buildRequirement(
              'One special character or more', hasSpecialChar, isIOS),
          _buildRequirement('One number or more', hasNumber, isIOS),
          _buildRequirement('Passwords match', passwordsMatch, isIOS),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isIOS
                ? (isMet
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle)
                : (isMet ? Icons.check_circle : Icons.circle_outlined),
            color: isMet ? Colors.green : Colors.white.withOpacity(0.3),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(double maxWidth, bool isIOS) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: isIOS
          ? CupertinoButton(
              color: isPasswordValid ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(12),
              onPressed: isPasswordValid && !_isLoading ? _resetPassword : null,
              child: _isLoading
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: isPasswordValid && !_isLoading ? _resetPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPasswordValid ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
