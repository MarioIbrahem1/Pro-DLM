import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:road_helperr/ui/screens/new_password_screen.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/home_screen.dart';
import 'package:road_helperr/services/notification_service.dart';
import 'dart:async';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Otp extends StatefulWidget {
  final String email;
  final Map<String, dynamic>? registrationData;

  const Otp({
    super.key,
    required this.email,
    this.registrationData,
  });

  static const routeName = "otpscreen";

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<Otp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  Timer? _timer;
  int _timeLeft = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.sendOTP(widget.email);
      if (response['success'] == true) {
        setState(() {
          _timeLeft = 60;
          _isResendEnabled = false;
        });
        _startTimer();
        NotificationService.showSuccess(
          context: context,
          title: 'OTP Sent',
          message: 'OTP has been sent to your email',
        );
      } else {
        NotificationService.showGenericError(
          context,
          response['error'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      NotificationService.showNetworkError(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      NotificationService.showValidationError(
        context,
        'Please enter a 6-digit OTP code',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.registrationData != null) {
        // Registration Flow
        final registerResponse = await ApiService.register(
          widget.registrationData!,
          _otpController.text,
        );

        if (registerResponse['success'] == true) {
          if (!mounted) return;

          NotificationService.showRegistrationSuccess(
            context,
            onConfirm: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          );
        } else {
          if (!mounted) return;

          NotificationService.showGenericError(
            context,
            registerResponse['error'] ?? 'Failed to complete registration',
          );
        }
      } else {
        // Password Reset Flow
        final response = await ApiService.verifyOTP(
          widget.email,
          _otpController.text,
        );

        if (response['success'] == true) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                email: widget.email,
              ),
            ),
          );
        } else {
          if (!mounted) return;

          NotificationService.showGenericError(
            context,
            response['error'] ?? 'Invalid OTP code',
          );
        }
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
  void dispose() {
    _controller.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final bgMain = isLight
        ? AppColors.getGradientStart(context)
        : AppColors.getBackgroundColor(context);
    final boxColor = isLight ? Colors.white : AppColors.getCardColor(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLight
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.getBackgroundColor(context),
                    AppColors.getCardColor(context)
                  ],
                ),
          color: bgMain,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  isLight
                      ? 'assets/images/chracters.png'
                      : 'assets/images/chracters.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  lang.otpVerification,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lang.enterOtpSentToEmail(widget.email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: boxColor,
                      inactiveFillColor: boxColor,
                      selectedFillColor: boxColor,
                      activeColor: isLight
                          ? AppColors.getSignAndRegister(context)
                          : Colors.white,
                      inactiveColor: isLight
                          ? AppColors.getSignAndRegister(context)
                          : Colors.white,
                      selectedColor: isLight
                          ? AppColors.getSignAndRegister(context)
                          : Colors.white,
                    ),
                    enableActiveFill: true,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isResendEnabled
                      ? 'Resend OTP'
                      : 'Resend in $_timeLeft seconds',
                  style: TextStyle(
                    color: _isResendEnabled
                        ? AppColors.getSignAndRegister(context)
                        : textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.getSignAndRegister(context),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          lang.verify,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_isResendEnabled)
                        TextButton(
                          onPressed: _resendOTP,
                          child: Text(
                            lang.resendOtp,
                            style: TextStyle(
                              color: AppColors.getSignAndRegister(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'dart:async';
// import 'constants.dart';
//
// class Otp extends StatefulWidget {
//   final String email;
//   static const String routeName = "otpscreen";
//
//   const Otp({super.key, required this.email});
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<Otp> with SingleTickerProviderStateMixin {
//   final TextEditingController _otpController = TextEditingController();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   Timer? _timer;
//   int _timeLeft = 60;
//   bool _isResendEnabled = false;
//   bool _isVerifyEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     startTimer();
//   }
//
//   void _setupAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//     _animationController.forward();
//   }
//
//   void startTimer() {
//     _isResendEnabled = false;
//     _timeLeft = 60;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_timeLeft > 0) {
//         setState(() {
//           _timeLeft--;
//         });
//       } else {
//         setState(() {
//           _isResendEnabled = true;
//         });
//         timer.cancel();
//       }
//     });
//   }
//
//   void _checkOtpFilled(String value) {
//     setState(() {
//       _isVerifyEnabled = value.length == 6;
//     });
//   }
//
//   Future<void> _verifyOtp() async {
//     // منطق التحقق من OTP
//   }
//
//   Future<void> _resendOtp() async {
//     if (!_isResendEnabled) return;
//     startTimer();
//     // منطق إعادة إرسال OTP
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: double.infinity,
//         decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/otp_image.png',
//                 height: 200,
//                 fit: BoxFit.contain,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'OTP Verification',
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Enter OTP sent to ${widget.email}',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.7),
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: PinCodeTextField(
//                   appContext: context,
//                   length: 6,
//                   controller: _otpController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   pinTheme: PinTheme(
//                     shape: PinCodeFieldShape.box,
//                     borderRadius: BorderRadius.circular(10),
//                     fieldHeight: 50,
//                     fieldWidth: 40,
//                     activeFillColor: AppColors.white,
//                     inactiveFillColor: AppColors.white.withOpacity(0.8),
//                     selectedFillColor: AppColors.white,
//                   ),
//                   enableActiveFill: true,
//                   onChanged: _checkOtpFilled,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isVerifyEnabled ? _verifyOtp : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isVerifyEnabled ? Colors.blue : Colors.white,
//                 ),
//                 child: Text(
//                   'Verify',
//                   style: TextStyle(
//                     color: _isVerifyEnabled ? Colors.white : Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: _isResendEnabled ? _resendOtp : null,
//                 child: Text(
//                   _isResendEnabled ? "Resend OTP" : "Resend in $_timeLeft sec",
//                   style: TextStyle(
//                     color: _isResendEnabled ? Colors.white : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _otpController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
// }