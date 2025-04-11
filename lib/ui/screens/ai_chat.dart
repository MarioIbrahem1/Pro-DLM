import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/home_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/notification_screen.dart';
import '../screens/bottomnavigationbar_screes/profile_screen.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';
import '../public_details/card_chat.dart';

class AiChat extends StatelessWidget {
  static const String routeName = "ai chat";
  final int _selectedIndex = 2;

  const AiChat({super.key});

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
                ? 0.02
                : isTablet
                    ? 0.03
                    : 0.04);
        double iconSize = size.width *
            (isDesktop
                ? 0.02
                : isTablet
                    ? 0.025
                    : 0.03);
        double imageSize = size.width *
            (isDesktop
                ? 0.15
                : isTablet
                    ? 0.2
                    : 0.3);
        double spacing = size.height *
            (isDesktop
                ? 0.04
                : isTablet
                    ? 0.05
                    : 0.06);
        double navBarHeight = size.height *
            (isDesktop
                ? 0.08
                : isTablet
                    ? 0.07
                    : 0.06);

        return Scaffold(
          backgroundColor: AppColors.cardColor,
          appBar: AppBar(
            backgroundColor: AppColors.cardColor,
            title: Text(
              TextStrings.appBarAiChat,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontFamily:
                    platform == TargetPlatform.iOS ? '.SF Pro Text' : null,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                platform == TargetPlatform.iOS
                    ? CupertinoIcons.back
                    : Icons.arrow_back,
                color: Colors.white,
                size: iconSize * 1.2,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
            toolbarHeight: navBarHeight,
          ),
          body: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
              child: Column(
                children: [
                  SizedBox(height: spacing),
                  Image.asset(
                    'assets/images/ai.png',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const InfoCard(
                            title: TextStrings.titleCard1,
                            subtitle: TextStrings.subTitleCard1,
                          ),
                          SizedBox(height: spacing * 0.3),
                          const InfoCard(
                            title: TextStrings.titleCard2,
                            subtitle: TextStrings.subTitleCard2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildChatInput(context, size, titleSize, iconSize, platform),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: CurvedNavigationBar(
              backgroundColor: AppColors.cardColor,
              color: AppColors.backGroundColor,
              animationDuration: const Duration(milliseconds: 300),
              height: navBarHeight,
              index: _selectedIndex,
              items: [
                Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.home
                        : Icons.home_outlined,
                    size: iconSize,
                    color: Colors.white),
                Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.location
                        : Icons.location_on_outlined,
                    size: iconSize,
                    color: Colors.white),
                Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.chat_bubble
                        : Icons.textsms_outlined,
                    size: iconSize,
                    color: Colors.white),
                Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.bell
                        : Icons.notifications_outlined,
                    size: iconSize,
                    color: Colors.white),
                Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.person
                        : Icons.person_2_outlined,
                    size: iconSize,
                    color: Colors.white),
              ],
              onTap: (index) => _handleNavigation(context, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInput(BuildContext context, Size size, double titleSize,
      double iconSize, TargetPlatform platform) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.02,
        horizontal: size.width * 0.04,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 60,
              ),
              child: TextField(
                style: TextStyle(
                  fontSize: titleSize * 0.8,
                  fontFamily:
                      platform == TargetPlatform.iOS ? '.SF Pro Text' : null,
                ),
                decoration: InputDecoration(
                  hintText: TextStrings.hintChatText,
                  hintStyle: TextStyle(
                    fontSize: titleSize * 0.8,
                    fontFamily:
                        platform == TargetPlatform.iOS ? '.SF Pro Text' : null,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      platform == TargetPlatform.iOS
                          ? CupertinoIcons.camera
                          : Icons.camera_alt_outlined,
                      color: AppColors.basicButton,
                      size: iconSize,
                    ),
                    onPressed: () {},
                  ),
                  contentPadding: EdgeInsets.all(size.width * 0.03),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Container(
            constraints: BoxConstraints(
              maxWidth: iconSize * 2.5,
              maxHeight: iconSize * 2.5,
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.aiElevatedButton,
              radius: iconSize,
              child: IconButton(
                icon: Icon(
                  platform == TargetPlatform.iOS
                      ? CupertinoIcons.arrow_right
                      : Icons.send,
                  color: Colors.white,
                  size: iconSize * 0.8,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      HomeScreen.routeName,
      MapScreen.routeName,
      AiWelcomeScreen.routeName,
      NotificationScreen.routeName,
      ProfileScreen.routeName,
    ];

    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }
}
