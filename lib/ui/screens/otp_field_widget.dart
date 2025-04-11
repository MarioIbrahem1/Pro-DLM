import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocus;
  final FocusNode? nextFocus;
  final Function({required String value, required FocusNode focusNode})
      nextField;
  final bool autofocus;

  const OtpFieldWidget({
    super.key,
    required this.controller,
    required this.currentFocus,
    required this.nextFocus,
    required this.nextField,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper(context: context);
        return _buildOtpField(responsive);
      },
    );
  }

  Widget _buildOtpField(ResponsiveHelper responsive) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(
        horizontal: responsive.horizontalSpacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: responsive.fieldWidth,
      height: responsive.fieldHeight,
      child: _buildTextField(responsive),
    );
  }

  Widget _buildTextField(ResponsiveHelper responsive) {
    return TextFormField(
      focusNode: currentFocus,
      autofocus: autofocus,
      maxLines: 1,
      maxLength: 1,
      controller: controller,
      keyboardType: TextInputType.number,
      cursorColor: const Color(0xFFA4A4A4),
      style: TextStyle(
        fontSize: responsive.fontSize,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      onChanged: _handleOnChanged,
      decoration: _buildInputDecoration(responsive),
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.top,
    );
  }

  InputDecoration _buildInputDecoration(ResponsiveHelper responsive) {
    return InputDecoration(
      counterText: '',
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        borderSide: const BorderSide(
          color: Color(0xFFA4A4A4),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(
        vertical: responsive.verticalPadding,
      ),
    );
  }

  void _handleOnChanged(String value) {
    if (value.isNotEmpty) {
      nextField(value: value, focusNode: currentFocus);
      if (nextFocus != null) {
        nextFocus?.requestFocus();
      }
    }
  }
}

class ResponsiveHelper {
  final BuildContext context;
  final Size size;

  ResponsiveHelper({required this.context})
      : size = MediaQuery.of(context).size;

  bool get isTablet => size.width > 600;
  bool get isDesktop => size.width > 1200;

  double get fieldWidth =>
      size.width *
      (isDesktop
          ? 0.04
          : isTablet
              ? 0.06
              : 0.15);
  double get fieldHeight => fieldWidth * 0.93; // maintain aspect ratio
  double get fontSize => fieldWidth * 0.4;
  double get borderRadius => 10;
  double get horizontalSpacing => 10;
  double get verticalPadding => fieldHeight * 0.1;
}

// Optional: Theme extension for consistent styling
extension OtpFieldTheme on ThemeData {
  Color get otpFieldBorderColor => const Color(0xFFA4A4A4);
  Color get otpFieldCursorColor => Colors.grey;
}

// Optional: Custom painter for additional styling if needed
class OtpFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Add custom painting logic here if needed
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
