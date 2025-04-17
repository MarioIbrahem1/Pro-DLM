import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/signupScreen.dart';
import 'dart:math' show min;
import 'constants.dart';
import 'package:road_helperr/ui/screens/OTPscreen.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/services/notification_service.dart';

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
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<void> _validateAndNavigate() async {
    print('_validateAndNavigate called');

    if (_emailController.text.isEmpty) {
      NotificationService.showError(
        context: context,
        title: 'Error',
        message: 'Please enter your email',
      );
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      NotificationService.showError(
        context: context,
        title: 'Error',
        message: 'Please enter a valid email',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Sending OTP request for: ${_emailController.text}');
      final response = await ApiService.sendOTP(_emailController.text);
      print('OTP send response: $response');

      if (response['success']) {
        print('OTP sent successfully, navigating to OTP screen');
        if (mounted) {
          NotificationService.showSuccess(
            context: context,
            title: 'OTP Sent',
            message:
                'OTP has been sent to your email: ${_emailController.text}',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otp(
                email: _emailController.text,
              ),
            ),
          );
        }
      } else {
        print('OTP send failed: ${response['error']}');
        if (mounted) {
          NotificationService.showError(
            context: context,
            title: 'Email Not Found',
            message: response['error'] ?? 'Failed to send OTP',
          );
        }
      }
    } catch (e) {
      print('Error in _validateAndNavigate: $e');
      if (mounted) {
        NotificationService.showError(
          context: context,
          title: 'Error',
          message: 'An error occurred while processing your request',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
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
              child: Form(
                key: _formKey,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!_isValidEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
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
