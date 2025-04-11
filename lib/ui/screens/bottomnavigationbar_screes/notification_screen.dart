import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart';
import 'package:road_helperr/utils/text_strings.dart';
import '../../../utils/app_colors.dart';
import 'home_screen.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = "notification";

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 3;

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
        double subtitleSize = titleSize * 0.8;
        double iconSize = size.width *
            (isDesktop
                ? 0.02
                : isTablet
                    ? 0.025
                    : 0.03);
        double navBarHeight = size.height *
            (isDesktop
                ? 0.08
                : isTablet
                    ? 0.07
                    : 0.06);
        double spacing = size.height * 0.02;

        return platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS
            ? _buildCupertinoLayout(context, size, titleSize, subtitleSize,
                iconSize, navBarHeight, spacing, isDesktop)
            : _buildMaterialLayout(context, size, titleSize, subtitleSize,
                iconSize, navBarHeight, spacing, isDesktop);
      },
    );
  }

  Widget _buildMaterialLayout(
    BuildContext context,
    Size size,
    double titleSize,
    double subtitleSize,
    double iconSize,
    double navBarHeight,
    double spacing,
    bool isDesktop,
  ) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          TextStrings.notify,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              TextStrings.clear,
              style: TextStyle(
                color: AppColors.switchColor,
                fontSize: subtitleSize,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(
          context, size, titleSize, subtitleSize, spacing, isDesktop),
      bottomNavigationBar:
          _buildMaterialNavBar(context, iconSize, navBarHeight, isDesktop),
    );
  }

  Widget _buildCupertinoLayout(
    BuildContext context,
    Size size,
    double titleSize,
    double subtitleSize,
    double iconSize,
    double navBarHeight,
    double spacing,
    bool isDesktop,
  ) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.cardColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.cardColor,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(
          TextStrings.notify,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontFamily: '.SF Pro Text',
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            TextStrings.clear,
            style: TextStyle(
              color: AppColors.switchColor,
              fontSize: subtitleSize,
              fontFamily: '.SF Pro Text',
            ),
          ),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(
                  context, size, titleSize, subtitleSize, spacing, isDesktop),
            ),
            _buildCupertinoNavBar(context, iconSize, navBarHeight, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Size size,
    double titleSize,
    double subtitleSize,
    double spacing,
    bool isDesktop,
  ) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 800 : 600,
        ),
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/Group 12.png",
              width: size.width * (isDesktop ? 0.3 : 0.5),
              fit: BoxFit.contain,
            ),
            SizedBox(height: spacing),
            Text(
              TextStrings.noNotify,
              style: TextStyle(
                color: AppColors.switchColor,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                fontFamily: isIOS ? '.SF Pro Text' : null,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            Text(
              TextStrings.notifyInbox,
              style: TextStyle(
                color: AppColors.switchColor,
                fontSize: subtitleSize,
                fontFamily: isIOS ? '.SF Pro Text' : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialNavBar(
    BuildContext context,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return Container(
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
          Icon(Icons.home_outlined, size: iconSize, color: Colors.white),
          Icon(Icons.location_on_outlined, size: iconSize, color: Colors.white),
          Icon(Icons.textsms_outlined, size: iconSize, color: Colors.white),
          Icon(Icons.notifications_outlined,
              size: iconSize, color: Colors.white),
          Icon(Icons.person_2_outlined, size: iconSize, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleNavigation(context, index);
        },
      ),
    );
  }

  Widget _buildCupertinoNavBar(
    BuildContext context,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 1200 : double.infinity,
      ),
      child: CupertinoTabBar(
        backgroundColor: AppColors.backGroundColor,
        activeColor: Colors.white,
        inactiveColor: Colors.white.withOpacity(0.6),
        height: navBarHeight,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: iconSize),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location, size: iconSize),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble, size: iconSize),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell, size: iconSize),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person, size: iconSize),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleNavigation(context, index);
        },
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

    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
