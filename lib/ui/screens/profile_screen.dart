import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_helperr/ui/screens/signin_screen.dart';
import 'dart:io';
import 'profile_ribon.dart';
import 'edit_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    name = widget.name; // استخدام القيم الممررة من الـ widget
    email = widget.email;
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

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
      // يمكنك إضافة منطق هنا لتغيير الثيم
    });
  }

  void _changeLanguage(String? newValue) {
    setState(() {
      selectedLanguage = newValue!;
      // يمكنك إضافة منطق هنا لتغيير اللغة
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01122A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40), // Space for status bar
            // Profile Avatar
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
            const SizedBox(height: 10),
            // Name and Email
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            // Profile Options
            ProfileRibon(
              leadingIcon: "assets/images/editable.png",
              title: "Edit Profile",
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, EditProfileScreen.routeName);
              },
            ),
            // Language Option with Dropdown
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    items: ["English", "اللغة العربية"].map((String value) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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








// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:road_helperr/ui/screens/signin_screen.dart';
// import 'dart:io';
// import 'profile_ribon.dart';
// import 'edit_profile_screen.dart';
//
// class PersonScreen extends StatefulWidget {
//   static const String routeName = "profscreen";
//   const PersonScreen({super.key});
//
//   @override
//   State<PersonScreen> createState() => _PersonScreenState();
// }
//
// class _PersonScreenState extends State<PersonScreen> {
//   File? _profileImage;
//   String name = "Mario Ebrahim";
//   String email = "Mario.Ebrahim@gmail.com";
//   bool isDarkMode = false;
//   String selectedLanguage = "English";
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _toggleDarkMode(bool value) {
//     setState(() {
//       isDarkMode = value;
//       // يمكنك إضافة منطق هنا لتغيير الثيم
//     });
//   }
//
//   void _changeLanguage(String? newValue) {
//     setState(() {
//       selectedLanguage = newValue!;
//       // يمكنك إضافة منطق هنا لتغيير اللغة
//     });
//   }
//
//   void _logout(BuildContext context) {
//     Navigator.pushReplacementNamed(context, SignInScreen.routeName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF01122A),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 40), // Space for status bar
//             // Profile Avatar
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundColor: Colors.white,
//                   child: CircleAvatar(
//                     radius: 55,
//                     backgroundImage: _profileImage != null
//                         ? FileImage(_profileImage!)
//                         : const AssetImage('assets/images/logo.png')
//                             as ImageProvider,
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 10,
//                   child: GestureDetector(
//                     onTap: _pickImage,
//                     child: const CircleAvatar(
//                       radius: 15,
//                       backgroundColor: Color(0xFF2C4874),
//                       child: Icon(
//                         Icons.edit,
//                         color: Colors.white,
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             // Name and Email
//             Text(
//               name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: const Color(0xFF1A2A3F),
//               ),
//               child: Text(
//                 email,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Profile Options
//             ProfileRibon(
//               leadingIcon: "assets/images/editable.png",
//               title: "Edit Profile",
//               onTap: () {
//                 Navigator.pushReplacementNamed(
//                     context, EditProfileScreen.routeName);
//               },
//             ),
//             // Language Option with Dropdown
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Row(
//                 children: [
//                   const ImageIcon(
//                     AssetImage("assets/images/lang_icon.png"),
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Language",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const Spacer(),
//                   DropdownButton<String>(
//                     value: selectedLanguage,
//                     dropdownColor: const Color(0xFF1A2A3F),
//                     onChanged: _changeLanguage,
//                     items: ["English", "اللغة العربية"].map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(
//                           value,
//                           style: const TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//             // Dark Mode Option with Toggle
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Row(
//                 children: [
//                   const ImageIcon(
//                     AssetImage("assets/images/mode.png"),
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Dark Mode",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const Spacer(),
//                   Switch(
//                     value: isDarkMode,
//                     onChanged: _toggleDarkMode,
//                     activeColor: Colors.white,
//                     activeTrackColor: const Color(0xFF023A87),
//                   ),
//                 ],
//               ),
//             ),
//             ProfileRibon(
//               leadingIcon: "assets/images/about_icon.png",
//               title: "About",
//               onTap: () {},
//             ),
//             ProfileRibon(
//               leadingIcon: "assets/images/logout.png",
//               title: "Logout",
//               onTap: () => _logout(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }