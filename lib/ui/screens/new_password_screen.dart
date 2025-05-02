import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'signin_screen.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/services/notification_service.dart';
import 'package:road_helperr/utils/app_colors.dart';

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

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool hasUpperCase = false;
  bool hasSpecialChar = false;
  bool hasNumber = false;
  bool passwordsMatch = false;
  bool _isLoading = false;
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
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
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
      hasUpperCase && hasSpecialChar && hasNumber && passwordsMatch;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: isIOS
            ? CupertinoNavigationBar(
                backgroundColor: Colors.transparent,
                border: null,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    CupertinoIcons.back,
                    color: AppColors.getSignAndRegister(context),
                  ),
                ),
              )
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.getSignAndRegister(context),
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
                      color: AppColors.getSignAndRegister(context),
                    ),
                    SizedBox(height: size.height * 0.04),
                    _buildPasswordField(maxWidth, isIOS, context),
                    SizedBox(height: size.height * 0.02),
                    _buildConfirmPasswordField(maxWidth, isIOS, context),
                    SizedBox(height: size.height * 0.02),
                    _buildPasswordRequirements(maxWidth, isIOS, context),
                    SizedBox(height: size.height * 0.04),
                    _buildResetButton(maxWidth, isIOS, context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      double maxWidth, bool isIOS, BuildContext context) {
    final hasError = _passwordController.text.isNotEmpty && !isPasswordValid;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : AppColors.getSignAndRegister(context),
        ),
        color: AppColors.getSurfaceColor(context),
      ),
      child: isIOS
          ? CupertinoTextField(
              controller: _passwordController,
              onChanged: _validatePassword,
              style: TextStyle(
                color: AppColors.getLabelTextField(context),
              ),
              obscureText: _obscurePassword,
              placeholder: 'New Password',
              placeholderStyle: TextStyle(
                color: AppColors.getLabelTextField(context).withOpacity(0.5),
              ),
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
                  color: AppColors.getSignAndRegister(context),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            )
          : TextField(
              controller: _passwordController,
              onChanged: _validatePassword,
              style: TextStyle(
                color: AppColors.getLabelTextField(context),
              ),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(
                  color: AppColors.getLabelTextField(context).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.getSignAndRegister(context),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
    );
  }

  Widget _buildConfirmPasswordField(
      double maxWidth, bool isIOS, BuildContext context) {
    final hasError =
        _confirmPasswordController.text.isNotEmpty && !passwordsMatch;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : AppColors.getSignAndRegister(context),
        ),
        color: AppColors.getSurfaceColor(context),
      ),
      child: isIOS
          ? CupertinoTextField(
              controller: _confirmPasswordController,
              onChanged: _validateConfirmPassword,
              style: TextStyle(
                color: AppColors.getLabelTextField(context),
              ),
              obscureText: _obscureConfirmPassword,
              placeholder: 'Rewrite New Password',
              placeholderStyle: TextStyle(
                color: AppColors.getLabelTextField(context).withOpacity(0.5),
              ),
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
                  color: AppColors.getSignAndRegister(context),
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            )
          : TextField(
              controller: _confirmPasswordController,
              onChanged: _validateConfirmPassword,
              style: TextStyle(
                color: AppColors.getLabelTextField(context),
              ),
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Rewrite New Password',
                hintStyle: TextStyle(
                  color: AppColors.getLabelTextField(context).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.getSignAndRegister(context),
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordRequirements(
      double maxWidth, bool isIOS, BuildContext context) {
    final mainColor = AppColors.getSignAndRegister(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.getSurfaceColor(context),
        border: Border.all(color: mainColor.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIOS ? CupertinoIcons.info : Icons.info_outline,
                color: mainColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Password must have:',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement(
              'One capital letter or more', hasUpperCase, isIOS, context),
          _buildRequirement(
              'One special character or more', hasSpecialChar, isIOS, context),
          _buildRequirement('One number or more', hasNumber, isIOS, context),
          _buildRequirement('Passwords match', passwordsMatch, isIOS, context),
        ],
      ),
    );
  }

  Widget _buildRequirement(
      String text, bool isMet, bool isIOS, BuildContext context) {
    final mainColor = AppColors.getSignAndRegister(context);
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
            color: isMet ? Colors.green : mainColor.withOpacity(0.4),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : mainColor.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(double maxWidth, bool isIOS, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              color: isPasswordValid
                  ? AppColors.getSignAndRegister(context)
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
              onPressed: isPasswordValid && !_isLoading ? _resetPassword : null,
              child: _isLoading
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: AppColors.onPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: isPasswordValid && !_isLoading ? _resetPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPasswordValid
                    ? AppColors.getSignAndRegister(context)
                    : Colors.grey,
                elevation: isPasswordValid ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimaryColor,
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
