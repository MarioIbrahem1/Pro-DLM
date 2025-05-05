import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "EditProfileScreen";
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
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
                    : 0.055);
        double iconSize = size.width *
            (isDesktop
                ? 0.015
                : isTablet
                    ? 0.02
                    : 0.025); // Adjusted icon size
        double avatarRadius = size.width *
            (isDesktop
                ? 0.08
                : isTablet
                    ? 0.1
                    : 0.15);
        double padding = size.width *
            (isDesktop
                ? 0.03
                : isTablet
                    ? 0.04
                    : 0.05);

        return Scaffold(
          backgroundColor: const Color(0xFF01122A),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_outlined,
                  color: Colors.white, size: iconSize * 1.2),
              onPressed: () {
                Navigator.of(context).pop(); // This will navigate back
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              lang.editProfile,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : 800,
              ),
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.04),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _image != null
                              ? FileImage(File(_image!.path))
                              : const AssetImage('assets/images/logo.png')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: avatarRadius * 0.3,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: avatarRadius * 0.25,
                              backgroundColor: const Color(0xFF2C4874),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  EditTextField(
                    label: lang.firstName,
                    icon: Icons.person, // Use IconData here
                    iconSize: 16, // Smaller icon size
                  ),
                  EditTextField(
                    label: lang.lastName,
                    icon: Icons.person, // Use IconData here
                    iconSize: 16, // Smaller icon size
                  ),
                  EditTextField(
                    label: lang.phoneNumber,
                    icon: Icons.phone, // Use IconData here
                    iconSize: 16, // Smaller icon size
                  ),
                   EditTextField(
                    label: lang.email,
                    icon: Icons.email, // Use IconData here
                    iconSize: 16, // Smaller icon size
                  ),
                   EditTextField(
                    label: lang.password,
                    icon: Icons.lock, // Use IconData here
                    iconSize: 16, // Smaller icon size
                    obscureText: true,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: padding),
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF01122A),
                        border: Border.all(
                          color: Colors.grey,
                          width: 3,
                        )),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/car_settings_icon.png",
                          width: iconSize * 1.5,
                          height: iconSize * 1.5,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          lang.carSettings,
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: titleSize * 0.7,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              carSettingsModalBottomSheet(context);
                            },
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: iconSize * 1.5,
                            ))
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                    child: SizedBox(
                      height: size.height * 0.06,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF023A87),
                          ),
                          child: Text(
                            lang.updateChanges,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: titleSize * 0.8,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void carSettingsModalBottomSheet(BuildContext context) {
    var lang = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to be scrollable
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            double iconSize = constraints.maxWidth * 0.06;
            double padding = constraints.maxWidth * 0.04;
            double fontSize = size.width * 0.04;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: Container(
                height: size.height * 0.4,
                padding: EdgeInsets.all(padding),
                color: const Color(0xFF01122A),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCarSettingInput(
                          lang.carNumber,
                          "assets/images/car_number.png",
                          iconSize,
                          padding,
                          fontSize),
                      _buildCarSettingInput(
                          lang.carColor,
                          "assets/images/car_color.png",
                          iconSize,
                          padding,
                          fontSize),
                      _buildCarSettingInput(
                          lang.carKind,
                          "assets/images/password_icon.png",
                          iconSize,
                          padding,
                          fontSize),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCarSettingInput(String title, String iconPath, double iconSize,
      double padding, double fontSize) {
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
              child: TextField(
                style: TextStyle(color: Colors.white, fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: title,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
