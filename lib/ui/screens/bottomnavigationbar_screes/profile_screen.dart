import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/profile_screen.dart';
import '../../../utils/app_colors.dart';
import 'home_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = "profile";
  final int _selectedIndex = 4;

  const ProfileScreen({super.key});

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
        double navBarHeight = size.height *
            (isDesktop
                ? 0.08
                : isTablet
                    ? 0.07
                    : 0.06);

        return platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS
            ? _buildCupertinoLayout(context, size, constraints, titleSize,
                iconSize, navBarHeight, isDesktop)
            : _buildMaterialLayout(context, size, constraints, titleSize,
                iconSize, navBarHeight, isDesktop);
      },
    );
  }

  Widget _buildMaterialLayout(
    BuildContext context,
    Size size,
    BoxConstraints constraints,
    double titleSize,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Screen',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: iconSize * 1.2,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: navBarHeight,
      ),
      body: _buildBody(context, size, isDesktop),
      bottomNavigationBar:
          _buildMaterialNavBar(context, iconSize, navBarHeight, isDesktop),
    );
  }

  Widget _buildCupertinoLayout(
    BuildContext context,
    Size size,
    BoxConstraints constraints,
    double titleSize,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Profile Screen',
          style: TextStyle(
            fontSize: titleSize,
            fontFamily: '.SF Pro Text',
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.back,
            size: iconSize * 1.2,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(context, size, isDesktop),
            ),
            _buildCupertinoNavBar(context, iconSize, navBarHeight, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Size size, bool isDesktop) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 1200 : double.infinity,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      child: const PersonScreen(
        name: '',
        email: '',
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
        onTap: (index) => _handleNavigation(context, index),
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
        onTap: (index) => _handleNavigation(context, index),
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
