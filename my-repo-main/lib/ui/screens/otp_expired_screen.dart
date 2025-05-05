import 'package:flutter/material.dart';
import 'package:road_helperr/ui/screens/otp_screen.dart';
import 'package:road_helperr/ui/screens/signin_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpExpiredScreen extends StatefulWidget {
  static const String routeName = "otpexpired";
  const OtpExpiredScreen({super.key});

  @override
  State<OtpExpiredScreen> createState() => _OtpExpiredScreenState();
}

class _OtpExpiredScreenState extends State<OtpExpiredScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper(
          context: context,
          constraints: constraints,
        );

        return Scaffold(
          backgroundColor: const Color.fromRGBO(1, 18, 42, 1),
          body: SafeArea(
            child: _buildMainContent(responsive),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(ResponsiveHelper responsive) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: responsive.maxContentWidth,
          ),
          padding: EdgeInsets.all(responsive.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWarningIcon(responsive),
              SizedBox(height: responsive.spacing),
              _buildErrorMessage(responsive),
              SizedBox(height: responsive.largeSpacing),
              _buildRequestOtpButton(responsive),
              SizedBox(height: responsive.spacing),
              _buildBackToLoginButton(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon(ResponsiveHelper responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AdaptiveIcon(
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        size: responsive.iconSize,
      ),
    );
  }

  Widget _buildErrorMessage(ResponsiveHelper responsive) {
    var lang = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AdaptiveText(
        lang.theOtpHasExpired,
        style: TextStyle(
          color: Colors.white,
          fontSize: responsive.titleSize,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRequestOtpButton(ResponsiveHelper responsive) {
    var lang = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AdaptiveButton(
        text:lang.requestOtp ,
        onPressed: () {
          Navigator.of(context).pushNamed(OtpScreen.routeName);
        },
        width: double.infinity,
        height: responsive.buttonHeight,
        maxWidth: responsive.buttonMaxWidth,
        fontSize: responsive.buttonFontSize,
        backgroundColor: Colors.blue,
        padding: responsive.buttonPadding,
      ),
    );
  }

  Widget _buildBackToLoginButton(ResponsiveHelper responsive) {
    var lang = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed(SignInScreen.routeName);
        },
        // onPressed: _handleBackToLogin,
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(responsive.padding * 0.5),
        ),
        child: Text(
          lang.backToLogin,
          style: TextStyle(
            color: Colors.blue,
            fontSize: responsive.buttonFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleRequestOtp() {
    onpressed() {
      Navigator.of(context).pushNamed(OtpScreen.routeName);
    }
  }

  void _handleBackToLogin() {
    onpressed() {
      Navigator.of(context).pushNamed(SignInScreen.routeName);
    }
  }
}

// Helper Classes
class ResponsiveHelper {
  final BuildContext context;
  final BoxConstraints constraints;
  final Size size;

  ResponsiveHelper({
    required this.context,
    required this.constraints,
  }) : size = MediaQuery.of(context).size;

  bool get isTablet => constraints.maxWidth > 600;
  bool get isDesktop => constraints.maxWidth > 1200;

  double get iconSize =>
      size.width *
      (isDesktop
          ? 0.08
          : isTablet
              ? 0.12
              : 0.15);
  double get titleSize =>
      size.width *
      (isDesktop
          ? 0.025
          : isTablet
              ? 0.035
              : 0.05);
  double get buttonFontSize =>
      size.width *
      (isDesktop
          ? 0.015
          : isTablet
              ? 0.025
              : 0.04);
  double get buttonHeight =>
      size.height *
      (isDesktop
          ? 0.06
          : isTablet
              ? 0.07
              : 0.08);
  double get padding =>
      size.width *
      (isDesktop
          ? 0.03
          : isTablet
              ? 0.04
              : 0.05);
  double get spacing => size.height * 0.02;
  double get largeSpacing => size.height * 0.05;

  double get maxContentWidth => isDesktop
      ? 800
      : isTablet
          ? 600
          : double.infinity;
  double get buttonMaxWidth => isDesktop
      ? 400
      : isTablet
          ? 300
          : double.infinity;

  EdgeInsets get buttonPadding => EdgeInsets.symmetric(vertical: padding * 0.5);
}

// Adaptive Widgets
class AdaptiveIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AdaptiveIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double maxWidth;
  final double fontSize;
  final Color backgroundColor;
  final EdgeInsets padding;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.maxWidth,
    required this.fontSize,
    required this.backgroundColor,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: padding,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
