import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/signupScreen.dart';
import 'dart:math' show min;
import 'constants.dart';
import 'OTPscreen.dart';
import 'package:road_helperr/services/api_service.dart';

class EmailScreen extends StatefulWidget {
  static const String routeName = "emailscreen";
  const EmailScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _moveAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );
  }

  void _validateAndNavigate() async {
    final String email = _emailController.text.trim();
    if (_isValidEmail(email)) {
      // Check if email exists
      final result = await ApiService.checkEmailExists(email);

      if (result.containsKey('error')) {
        _showErrorMessage(result['error']);
        return;
      }

      if (!result['exists']) {
        _showErrorMessage('مفيش اكونت متسجل على الايميل ده');
        return;
      }

      // If email exists, send OTP and navigate
      final otpResult = await ApiService.sendOTP(email);

      if (otpResult.containsKey('error')) {
        _showErrorMessage(otpResult['error']);
        return;
      }

      // If OTP sent successfully, navigate to OTP screen
      if (mounted) {
        final platform = Theme.of(context).platform;
        Navigator.push(
          context,
          platform == TargetPlatform.iOS
              ? CupertinoPageRoute(builder: (context) => Otp(email: email))
              : MaterialPageRoute(builder: (context) => Otp(email: email)),
        );
      }
    } else {
      _showErrorMessage('الرجاء إدخال بريد إلكتروني صحيح');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _showErrorMessage([String? message]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'حدث خطأ غير متوقع'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    final double paddingHorizontal = size.width * 0.1;
    const double maxWidth = 450.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: size.height * 0.05,
                ),
                child: Column(
                  children: [
                    _buildAnimatedImage(),
                    _buildHeaderTexts(size),
                    _buildEmailInput(size, isIOS),
                    _buildGetOTPButton(size, isIOS),
                    _buildRegisterLink(size),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(0.0, _moveAnimation.value)
                ..scale(_scaleAnimation.value),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(0, 5 + (_moveAnimation.value * 0.2)),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/otp_image.png',
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderTexts(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.03),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'OTP Verification',
              style: TextStyle(
                color: AppColors.white,
                fontSize: min(size.width * 0.06, 24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'We will send you an One Time Password\non your email address',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: min(size.width * 0.04, 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput(Size size, bool isIOS) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: isIOS
          ? CupertinoTextField(
              controller: _emailController,
              style: TextStyle(
                color: AppColors.white,
                fontSize: min(size.width * 0.04, 16),
              ),
              placeholder: 'Enter your email',
              placeholderStyle: TextStyle(
                color: AppColors.white.withOpacity(0.5),
                fontSize: min(size.width * 0.04, 16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: 16,
              ),
              keyboardType: TextInputType.emailAddress,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
            )
          : TextFormField(
              controller: _emailController,
              style: TextStyle(
                color: AppColors.white,
                fontSize: min(size.width * 0.04, 16),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  color: AppColors.white.withOpacity(0.5),
                  fontSize: min(size.width * 0.04, 16),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
    );
  }

  Widget _buildGetOTPButton(Size size, bool isIOS) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      height: 48,
      margin: EdgeInsets.only(top: size.height * 0.03),
      child: isIOS
          ? CupertinoButton(
              color: const Color.fromARGB(255, 119, 146, 184),
              borderRadius: BorderRadius.circular(12),
              onPressed: _validateAndNavigate,
              child: Text(
                'Get OTP',
                style: TextStyle(
                  fontSize: min(size.width * 0.04, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: _validateAndNavigate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 162, 172, 185),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Get OTP',
                style: TextStyle(
                  fontSize: min(size.width * 0.04, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildRegisterLink(Size size) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.02),
      child: Center(
        child: TextButton(
          onPressed: () {
            // Navigate to Registration Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            );
          },
          child: Text(
            "Don't Have An Account? Register",
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: min(size.width * 0.035, 14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
