import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_switch.dart';
import '../about_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_helperr/ui/screens/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:road_helperr/services/profile_service.dart';
import 'package:road_helperr/models/profile_data.dart';
import '../edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "profscreen";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String selectedLanguage = "English";
  String currentTheme = "System";
  ProfileData? _profileData;
  bool isLoading = true;

  static const int _selectedIndex = 4;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProfileImage();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('logged_in_email');
      if (userEmail != null && userEmail.isNotEmpty) {
        email = userEmail;
        // Load profile data from API or local
        final profileData = await _profileService.getProfileData(userEmail);
        // Load profile image from profileData/profileImage
        if (mounted) {
          setState(() {
            _profileData = profileData;
            name = profileData.name;
            email = profileData.email;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      if (email.isNotEmpty) {
        final imageUrl = await _profileService.getProfileImage(email);
        if (mounted && imageUrl.isNotEmpty) {
          setState(() {
            if (_profileData != null) {
              _profileData = ProfileData(
                name: _profileData!.name,
                email: _profileData!.email,
                phone: _profileData!.phone,
                address: _profileData!.address,
                profileImage: imageUrl,
                carModel: _profileData!.carModel,
                carColor: _profileData!.carColor,
                plateNumber: _profileData!.plateNumber,
              );
            } else {
              _profileData = ProfileData(
                name: name,
                email: email,
                profileImage: imageUrl,
              );
            }
          });
        }
      }
    } catch (e) {
      // ignore error, fallback to default
    }
  }

  void _changeLanguage(String? newValue) {
    setState(() {
      selectedLanguage = newValue!;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF01122A),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text(
              'profile',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF86A5D9)
                        : const Color(0xFF1F3551),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildProfileImage(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 230),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Text(
                        name,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildListTile(
                                icon: Icons.edit_outlined,
                                title: "Edit Profile",
                                onTap: _navigateToEditProfile,
                              ),
                              const SizedBox(height: 5),
                              _buildLanguageSelector(),
                              const SizedBox(height: 5),
                              _buildThemeSelector(),
                              const SizedBox(height: 5),
                              _buildListTile(
                                icon: Icons.info_outline,
                                title: "About",
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AboutScreen.routeName);
                                },
                              ),
                              const SizedBox(height: 5),
                              _buildListTile(
                                icon: Icons.logout,
                                title: "Logout",
                                onTap: () => _logout(context),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF01122A),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F3551)
            : AppColors.getBackgroundColor(context),
        buttonBackgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F3551)
            : AppColors.getBackgroundColor(context),
        animationDuration: const Duration(milliseconds: 300),
        height: 50,
        index: _selectedIndex,
        items: const [
          Icon(Icons.home_outlined, size: 20, color: Colors.white),
          Icon(Icons.location_on_outlined, size: 20, color: Colors.white),
          Icon(Icons.textsms_outlined, size: 20, color: Colors.white),
          Icon(Icons.notifications_outlined, size: 20, color: Colors.white),
          Icon(Icons.person_2_outlined, size: 20, color: Colors.white),
        ],
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector() {
    return _buildListTile(
      icon: Icons.language,
      title: "Language",
      trailing: PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedLanguage,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              size: 16,
            ),
          ],
        ),
        color: const Color(0xFF1F3551),
        onSelected: (String value) {
          setState(() {
            selectedLanguage = value;
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "English",
            child: Text(
              'English',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const PopupMenuItem<String>(
            value: "العربية",
            child: Text(
              'العربية',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildThemeSelector() {
    return _buildListTile(
      icon: Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoIcons.paintbrush
          : Icons.palette_outlined,
      title: "Theme",
      trailing: const ThemeSwitch(),
      onTap: () {},
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 65,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFF86A5D9)
              : Colors.white,
          backgroundImage: (_profileData?.profileImage != null &&
                  _profileData!.profileImage!.isNotEmpty)
              ? NetworkImage(_profileData!.profileImage!)
              : null,
          child: (_profileData?.profileImage == null ||
                  _profileData!.profileImage!.isEmpty)
              ? const Icon(Icons.person, size: 65, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF023A87)
                  : const Color(0xFF1F3551),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
              onPressed: _pickAndUploadImage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          isLoading = true;
        });
        final File imageFile = File(image.path);
        final String imageUrl =
            await _profileService.uploadProfileImage(email, imageFile);
        if (mounted) {
          setState(() {
            if (_profileData != null) {
              _profileData = ProfileData(
                name: _profileData!.name,
                email: _profileData!.email,
                phone: _profileData!.phone,
                address: _profileData!.address,
                profileImage: imageUrl,
                carModel: _profileData!.carModel,
                carColor: _profileData!.carColor,
                plateNumber: _profileData!.plateNumber,
              );
            } else {
              _profileData = ProfileData(
                name: name,
                email: email,
                profileImage: imageUrl,
              );
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
    // بعد الرفع، هات الصورة من السيرفر تاني
    await _fetchProfileImage();
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index != _selectedIndex) {
      final routes = [
        HomeScreen.routeName,
        MapScreen.routeName,
        AiWelcomeScreen.routeName,
        NotificationScreen.routeName,
        ProfileScreen.routeName,
      ];
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
