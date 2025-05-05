import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:road_helperr/ui/screens/new_password_screen.dart';
import 'dart:async';
import 'constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Otp extends StatefulWidget {
  final String email;
  static const String routeName = "otpscreen";

  const Otp({super.key, required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<Otp> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  int _timeLeft = 60;
  bool _isResendEnabled = false;
  bool _isVerifyEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    startTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void startTimer() {
    _isResendEnabled = false;
    _timeLeft = 60;
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

  void _checkOtpFilled(String value) {
    setState(() {
      _isVerifyEnabled = value.length == 6;
    });
  }

  Future<void> _verifyOtp() async {
    // منطق التحقق من OTP
  }

  Future<void> _resendOtp() async {
    if (!_isResendEnabled) return;
    startTimer();
    // منطق إعادة إرسال OTP
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/otp_image.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                 Text(
                  lang.otpVerification,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter OTP sent to ${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
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
                      activeFillColor: AppColors.white,
                      inactiveFillColor: AppColors.white.withOpacity(0.8),
                      selectedFillColor: AppColors.white,
                    ),
                    enableActiveFill: true,
                    onChanged: _checkOtpFilled,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isVerifyEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NewPasswordScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isVerifyEnabled ? Colors.blue : Colors.white,
                  ),
                  child: Text(
                   lang.verify,
                    style: TextStyle(
                      color: _isVerifyEnabled ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isResendEnabled ? _resendOtp : null,
                  child: Text(
                    _isResendEnabled
                        ? lang.resendOtp
                        : "Resend in $_timeLeft sec",
                    style: TextStyle(
                      color: _isResendEnabled ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
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