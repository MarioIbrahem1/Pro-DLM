import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'signin_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool hasUpperCase = false;
  bool hasSpecialChar = false;
  bool hasNumber = false;
  bool passwordsMatch = false;
  bool isLoading = false;
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

  Future<void> _handleResetPassword() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      _showSuccessDialog();
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isPasswordValid)
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              color: isPasswordValid
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
              onPressed:
                  isPasswordValid && !isLoading ? _handleResetPassword : null,
              child: isLoading
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white)
                  : const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed:
                  isPasswordValid && !isLoading ? _handleResetPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPasswordValid ? Colors.blue : Colors.grey,
                elevation: isPasswordValid ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
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
                      ),
                    ),
            ),
    );
  }

  void _showSuccessDialog() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success!'),
          content: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Password reset successfully'),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F3551),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Password reset successfully',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
