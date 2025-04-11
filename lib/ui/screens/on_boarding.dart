import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'signin_screen.dart';
import 'signupScreen.dart';

class OnBoarding extends StatefulWidget {
  static const String routeName = "onboarding";
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showLocationDisabledMessage();
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showLocationDisabledMessage();
        }
      }
    }
  }

  void _showLocationDisabledMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: const Text('Please enable location services to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;
        final responsive = _ResponsiveSize(size, isDesktop, isTablet);

        return Scaffold(
          body: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/background_photo.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300]);
                      },
                    ),
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: responsive.maxContentWidth,
                              ),
                              padding: responsive.contentPadding,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(height: responsive.spacing),
                                  _AdaptiveImage(
                                    imagePath: "assets/images/car_rental.png",
                                    width: responsive.imageWidth,
                                    height: responsive.imageHeight,
                                  ),
                                  _AdaptiveText(
                                    text:
                                        "If you've got the time,\nwe've got the shine",
                                    style: TextStyle(
                                      fontSize: responsive.titleSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  _AdaptiveText(
                                    text:
                                        "JUST THE PROTECTION\nYOU and your CAR NEED\nSPEAK TO US FOR BEST SERVICES",
                                    style: TextStyle(
                                      fontSize: responsive.subtitleSize,
                                      color: const Color(0xFFD6D1D1),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive.spacing),
                                  _AdaptiveButtonRow(
                                    buttonWidth: responsive.buttonWidth,
                                    buttonHeight: responsive.buttonHeight,
                                    spacing: responsive.buttonSpacing,
                                    onSignUpPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen()),
                                    ),
                                    onSignInPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignInScreen()),
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacing),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// Helper classes for better organization and reusability
class _ResponsiveSize {
  final Size size;
  final bool isDesktop;
  final bool isTablet;

  _ResponsiveSize(this.size, this.isDesktop, this.isTablet);

  double get maxContentWidth => isDesktop ? 1200 : 800;

  EdgeInsets get contentPadding => EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      );

  double get titleSize =>
      size.width *
      (isDesktop
          ? 0.025
          : isTablet
              ? 0.035
              : 0.08);
  double get subtitleSize => titleSize * 0.5;
  double get buttonWidth =>
      size.width *
      (isDesktop
          ? 0.12
          : isTablet
              ? 0.2
              : 0.4);
  double get buttonHeight =>
      size.height *
      (isDesktop
          ? 0.06
          : isTablet
              ? 0.07
              : 0.08);
  double get imageWidth =>
      size.width *
      (isDesktop
          ? 0.3
          : isTablet
              ? 0.4
              : 0.8);
  double get imageHeight => imageWidth * 0.53;
  double get spacing => size.height * 0.02;
  double get buttonSpacing => size.width * 0.03;
}

class _AdaptiveImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const _AdaptiveImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }
}

class _AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const _AdaptiveText({
    required this.text,
    required this.style,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

class _AdaptiveButtonRow extends StatelessWidget {
  final double buttonWidth;
  final double buttonHeight;
  final double spacing;
  final VoidCallback onSignUpPressed;
  final VoidCallback onSignInPressed;

  const _AdaptiveButtonRow({
    required this.buttonWidth,
    required this.buttonHeight,
    required this.spacing,
    required this.onSignUpPressed,
    required this.onSignInPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: [
        _buildButton(
          context,
          "Sign up",
          Colors.white,
          const Color(0xFF2C2C2C),
          onSignUpPressed,
        ),
        _buildButton(
          context,
          "Sign in",
          const Color(0xFF02285E),
          Colors.white,
          onSignInPressed,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: buttonWidth * 0.12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
