import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/profile_screen.dart';
import 'package:road_helperr/ui/screens/signin_screen.dart';
import 'package:road_helperr/services/profile_service.dart';
import 'package:road_helperr/models/profile_data.dart';
import '../../../utils/app_colors.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../profile_ribon.dart';
import '../edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "profile";
  final int _selectedIndex = 4;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  bool isLoading = true;
  final ProfileService _profileService = ProfileService();
  File? _profileImage;
  bool isDarkMode = false;
  String selectedLanguage = "English";
  ProfileData? _profileData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Loading user data...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('logged_in_email');
      print('Loaded email from prefs: $userEmail');

      if (userEmail != null && userEmail.isNotEmpty) {
        setState(() {
          email = userEmail;
        });

        // Load profile data from API
        try {
          final profileData = await _profileService.getProfileData(userEmail);
          print('Loaded profile data: ${profileData.toJson()}');
          if (mounted) {
            setState(() {
              _profileData = profileData;
              name = profileData.name;
              email = profileData.email;
              isLoading = false;
            });
          }
        } catch (e) {
          print('Error loading profile data: $e');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading profile: $e')),
            );
          }
        }
      } else {
        print('No email found, redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      }
    } catch (e) {
      print('Error in _loadUserData: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          email: email,
          initialData: _profileData,
        ),
      ),
    );

    if (result != null && result is ProfileData) {
      setState(() {
        _profileData = result;
        name = result.name;
        email = result.email;
      });
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedLanguage = newValue;
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
  }

  void carSettingsModalBottomSheet(BuildContext context) {
    final carData = _profileData?.address?.split('\n');
    final carModel = carData?[0].split(': ')[1] ?? '';
    final carColor = carData?[1].split(': ')[1] ?? '';
    final plateNumber = carData?[2].split(': ')[1] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            double iconSize = constraints.maxWidth * 0.06;
            double padding = constraints.maxWidth * 0.04;
            double fontSize = size.width * 0.04;

            return Container(
              height: size.height * 0.4,
              padding: EdgeInsets.all(padding),
              decoration: const BoxDecoration(
                color: Color(0xFF01122A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCarSettingInput(
                      "Car Model",
                      "assets/images/car_number.png",
                      iconSize,
                      padding,
                      fontSize,
                      initialValue: carModel,
                    ),
                    _buildCarSettingInput(
                      "Car Color",
                      "assets/images/car_color.png",
                      iconSize,
                      padding,
                      fontSize,
                      initialValue: carColor,
                    ),
                    _buildCarSettingInput(
                      "Plate Number",
                      "assets/images/password_icon.png",
                      iconSize,
                      padding,
                      fontSize,
                      initialValue: plateNumber,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCarSettingInput(
    String title,
    String iconPath,
    double iconSize,
    double padding,
    double fontSize, {
    String? initialValue,
  }) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF01122A),
          border: Border.all(color: Colors.grey, width: 3),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),
            SizedBox(width: padding),
            Expanded(
              child: Text(
                initialValue ?? title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profileData != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : _profileData?.profileImage != null
                                      ? NetworkImage(
                                          _profileData!.profileImage!)
                                      : const AssetImage(
                                              'assets/images/logo.png')
                                          as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Color(0xFF2C4874),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _profileData!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFF1A2A3F),
                        ),
                        child: Text(
                          _profileData!.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProfileRibon(
                        leadingIcon: "assets/images/editable.png",
                        title: "Edit Profile",
                        onTap: _navigateToEditProfile,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const ImageIcon(
                              AssetImage("assets/images/lang_icon.png"),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Language",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: selectedLanguage,
                              dropdownColor: const Color(0xFF1A2A3F),
                              onChanged: _changeLanguage,
                              items: ["English", "اللغة العربية"]
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const ImageIcon(
                              AssetImage("assets/images/mode.png"),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Dark Mode",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: isDarkMode,
                              onChanged: _toggleDarkMode,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF023A87),
                            ),
                          ],
                        ),
                      ),
                      ProfileRibon(
                        leadingIcon: "assets/images/about_icon.png",
                        title: "About",
                        onTap: () {},
                      ),
                      ProfileRibon(
                        leadingIcon: "assets/images/logout.png",
                        title: "Logout",
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'No profile data available',
                    style: TextStyle(color: Colors.white),
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
        index: widget._selectedIndex,
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
        currentIndex: widget._selectedIndex,
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

class PersonScreen extends StatefulWidget {
  static const String routeName = "profscreen";
  final String name;
  final String email;

  const PersonScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  File? _profileImage;
  late String name;
  late String email;
  bool isDarkMode = false;
  String selectedLanguage = "English";
  final ProfileService _profileService = ProfileService();
  ProfileData? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    email = widget.email;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final profileData = await _profileService.getProfileData(widget.email);
      print('Loaded profile data: ${profileData.toJson()}');

      if (mounted) {
        setState(() {
          _profileData = profileData;
          name = profileData.name;
          email = profileData.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          email: email,
          initialData: _profileData,
        ),
      ),
    );

    if (result != null && result is ProfileData) {
      setState(() {
        _profileData = result;
        name = result.name;
        email = result.email;
      });
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedLanguage = newValue;
      });
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01122A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : _profileData?.profileImage != null
                                  ? NetworkImage(_profileData!.profileImage!)
                                  : const AssetImage('assets/images/logo.png')
                                      as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Color(0xFF2C4874),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Display name
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display email
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF1A2A3F),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileRibon(
                    leadingIcon: "assets/images/editable.png",
                    title: "Edit Profile",
                    onTap: _navigateToEditProfile,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const ImageIcon(
                          AssetImage("assets/images/lang_icon.png"),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Language",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: selectedLanguage,
                          dropdownColor: const Color(0xFF1A2A3F),
                          onChanged: _changeLanguage,
                          items:
                              ["English", "اللغة العربية"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Dark Mode Option with Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const ImageIcon(
                          AssetImage("assets/images/mode.png"),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Dark Mode",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isDarkMode,
                          onChanged: _toggleDarkMode,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF023A87),
                        ),
                      ],
                    ),
                  ),
                  ProfileRibon(
                    leadingIcon: "assets/images/about_icon.png",
                    title: "About",
                    onTap: () {},
                  ),
                  ProfileRibon(
                    leadingIcon: "assets/images/logout.png",
                    title: "Logout",
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
    );
  }
}
