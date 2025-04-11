import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';
import 'package:road_helperr/ui/screens/ai_chat.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';
import 'package:road_helperr/utils/responsive_helper.dart';

class AiButton extends StatelessWidget {
  const AiButton({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    // تحديد المنصة
    final platform = Theme.of(context).platform;

    // احصل على أبعاد الشاشة
    final screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب الأبعاد الأساسية
        final dimensions = _calculateDimensions(screenSize, constraints);

        return Center(
          child: Container(
            constraints: _getAdaptiveConstraints(platform),
            width: dimensions.width,
            height: dimensions.height,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: dimensions.width,
                height: dimensions.height,
                child: _buildAdaptiveSlider(
                  context,
                  platform,
                  dimensions,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // حساب الأبعاد حسب حجم الشاشة
  _Dimensions _calculateDimensions(
      Size screenSize, BoxConstraints constraints) {
    double width = screenSize.width * 0.85;
    double height = screenSize.height * 0.08;
    double fontSize = screenSize.width * 0.045;

    if (constraints.maxWidth > 600) {
      // tablet
      width = screenSize.width * 0.6;
      height = screenSize.height * 0.07;
      fontSize = screenSize.width * 0.035;
    }
    if (constraints.maxWidth > 1200) {
      // desktop
      width = screenSize.width * 0.4;
      height = screenSize.height * 0.06;
      fontSize = screenSize.width * 0.025;
    }

    return _Dimensions(width, height, fontSize);
  }

  // الحصول على الـ constraints المناسبة للمنصة
  BoxConstraints _getAdaptiveConstraints(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BoxConstraints(
          maxWidth: 500,
          minWidth: 200,
          maxHeight: 70,
          minHeight: 45,
        );
      case TargetPlatform.windows:
        return const BoxConstraints(
          maxWidth: 600,
          minWidth: 250,
          maxHeight: 80,
          minHeight: 50,
        );
      default:
        return const BoxConstraints(
          maxWidth: 600,
          minWidth: 200,
          maxHeight: 80,
          minHeight: 50,
        );
    }
  }

  // بناء الـ slider المتكيف مع المنصة
  Widget _buildAdaptiveSlider(
    BuildContext context,
    TargetPlatform platform,
    _Dimensions dimensions,
  ) {
    // تخصيص الألوان والتأثيرات حسب المنصة
    final gradientColors = _getPlatformGradientColors(platform);
    final backgroundColor = _getPlatformBackgroundColor(platform);
    return GradientSlideToAct(
      text: TextStrings.getStarted,
      sliderButtonIcon: _getPlatformIcon(platform),
      textStyle: _getAdaptiveTextStyle(context, platform, dimensions.fontSize),
      backgroundColor: backgroundColor,
      width: dimensions.width,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      onSubmit: () {
        _navigateToAiChat(context, platform);
        debugPrint("Submitted!");
      },
      dragableIcon: Icons.arrow_forward_ios, // تم التصحيح هنا
    );
  }

  // الحصول على نمط النص المناسب للمنصة
  TextStyle _getAdaptiveTextStyle(
    BuildContext context,
    TargetPlatform platform,
    double fontSize,
  ) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text',
        );
      case TargetPlatform.windows:
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          fontFamily: 'Segoe UI',
        );
      default:
        return TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        );
    }
  }

  // الحصول على ألوان التدرج المناسبة للمنصة
  List<Color> _getPlatformGradientColors(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return [
          Colors.blue.shade300,
          Colors.blue.shade400,
          AppColors.aiElevatedButton,
          AppColors.aiElevatedButton,
        ];
      default:
        return const [
          Colors.blue,
          Colors.blue,
          AppColors.aiElevatedButton,
          AppColors.aiElevatedButton,
        ];
    }
  }

  // الحصول على لون الخلفية المناسب للمنصة
  Color _getPlatformBackgroundColor(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppColors.aiElevatedButton2.withOpacity(0.9);
      default:
        return AppColors.aiElevatedButton2;
    }
  }

  // الحصول على الأيقونة المناسبة للمنصة
  IconData _getPlatformIcon(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoIcons.chat_bubble_fill;
      default:
        return Icons.insert_comment_sharp;
    }
  }

  // الحصول على أيقونة السحب المناسبة للمنصة
  Widget? _getPlatformDragableIcon(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const Icon(
          CupertinoIcons.chevron_right,
          color: Colors.white,
          size: 24,
        );
      default:
        return null;
    }
  }

  // التنقل إلى شاشة AI Chat بشكل متكيف
  void _navigateToAiChat(BuildContext context, TargetPlatform platform) {
    Navigator.push(
      context,
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
          ? CupertinoPageRoute(builder: (context) => const AiChat())
          : MaterialPageRoute(builder: (context) => const AiChat()),
    );
  }
}

// كلاس مساعد لتخزين الأبعاد
class _Dimensions {
  final double width;
  final double height;
  final double fontSize;

  _Dimensions(this.width, this.height, this.fontSize);
}
