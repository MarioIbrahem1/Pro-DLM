import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/public_details/ai_button.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';
import 'package:road_helperr/ui/screens/ai_chat.dart';

class AiWelcomeScreen extends StatelessWidget {
  static const String routeName = "aiwelcomescreen";
  const AiWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;

        double titleSize = size.width *
            (isDesktop
                ? 0.025
                : isTablet
                    ? 0.035
                    : 0.045);
        double subtitleSize = titleSize * 0.6;
        double imageHeight = size.height *
            (isDesktop
                ? 0.4
                : isTablet
                    ? 0.35
                    : 0.3);
        double padding = size.width *
            (isDesktop
                ? 0.05
                : isTablet
                    ? 0.04
                    : 0.03);
        double spacing = size.height * 0.02;

        return platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS
            ? CupertinoPageScaffold(
                backgroundColor: AppColors.cardColor,
                child: _buildContent(
                  context,
                  size,
                  titleSize,
                  subtitleSize,
                  imageHeight,
                  padding,
                  spacing,
                  isDesktop,
                  true,
                ),
              )
            : Scaffold(
                backgroundColor: AppColors.cardColor,
                body: _buildContent(
                  context,
                  size,
                  titleSize,
                  subtitleSize,
                  imageHeight,
                  padding,
                  spacing,
                  isDesktop,
                  false,
                ),
              );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Size size,
    double titleSize,
    double subtitleSize,
    double imageHeight,
    double padding,
    double spacing,
    bool isDesktop,
    bool isIOS,
  ) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : 800,
          ),
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: isDesktop ? 500 : 400,
                  ),
                  padding: EdgeInsets.only(bottom: spacing),
                  child: Image.asset(
                    'assets/images/bot.png',
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: spacing * 1.5),
                Text(
                  TextStrings.text1Ai,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: isIOS ? '.SF Pro Text' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing),
                Padding(
                  padding: EdgeInsets.all(padding * 0.25),
                  child: Text(
                    TextStrings.text2Ai,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: subtitleSize,
                      fontFamily: isIOS ? '.SF Pro Text' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: spacing * 3),
                _buildNavigationButton(context, isIOS),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, bool isIOS) {
    return GestureDetector(
      onTap: () {
        if (isIOS) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const AiChat(),
            ),
          );
        } else {
          Navigator.pushNamed(context, AiChat.routeName);
        }
      },
      child: const AiButton(),
    );
  }
}
