import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_helperr/services/profile_service.dart';
import 'package:road_helperr/models/profile_data.dart';
import 'edit_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "EditProfileScreen";
  final String email;
  final ProfileData? initialData;

  const EditProfileScreen({
    super.key,
    required this.email,
    this.initialData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carKindController = TextEditingController();
  final _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('EditProfileScreen initialized with email: ${widget.email}');
    if (widget.initialData != null) {
      print('Initial data: ${widget.initialData!.toJson()}');
      final nameParts = widget.initialData!.name.split(' ');
      _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
      _lastNameController.text =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _phoneController.text = widget.initialData!.phone ?? '';
      _emailController.text = widget.initialData!.email;
      _carNumberController.text = widget.initialData!.plateNumber ?? '';
      _carColorController.text = widget.initialData!.carColor ?? '';
      _carKindController.text = widget.initialData!.carModel ?? '';
    } else {
      print('No initial data provided');
      _emailController.text = widget.email;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _carNumberController.dispose();
    _carColorController.dispose();
    _carKindController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = ProfileData(
        name:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                .trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        carModel: _carKindController.text.trim(),
        carColor: _carColorController.text.trim(),
        plateNumber: _carNumberController.text.trim(),
      );

      print('Updating profile with data: ${updatedData.toJson()}');
      await _profileService.updateProfileData(widget.email, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedData);
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    : 0.025);
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
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 800,
                    ),
                    padding: EdgeInsets.all(padding),
                    child: Form(
                      key: _formKey,
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
                                      : widget.initialData?.profileImage != null
                                          ? NetworkImage(
                                              widget.initialData!.profileImage!)
                                          : const AssetImage(
                                                  'assets/images/logo.png')
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
                            label: "First Name",
                            icon: Icons.person,
                            iconSize: 16,
                            controller: _firstNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          EditTextField(
                            label: "Last Name",
                            icon: Icons.person,
                            iconSize: 16,
                            controller: _lastNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          EditTextField(
                            label: "Phone Number",
                            icon: Icons.phone,
                            iconSize: 16,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          EditTextField(
                            label: "Email",
                            icon: Icons.email,
                            iconSize: 16,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: padding),
                            padding: EdgeInsets.all(padding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xFF01122A),
                              border: Border.all(
                                color: Colors.grey,
                                width: 3,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/car_settings_icon.png",
                                  width: iconSize * 1.5,
                                  height: iconSize * 1.5,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Text(
                                  "Car Settings",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: titleSize * 0.7,
                                    color: Colors.white,
                                  ),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.1),
                            child: SizedBox(
                              height: size.height * 0.06,
                              child: ElevatedButton(
                                onPressed: _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF023A87),
                                ),
                                child: Text(
                                  "Update Changes",
                                  style: TextStyle(
                                    fontSize: titleSize * 0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  void carSettingsModalBottomSheet(BuildContext context) {
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
                      "Car Number",
                      "assets/images/car_number.png",
                      _carNumberController,
                    ),
                    _buildCarSettingInput(
                      "Car Color",
                      "assets/images/car_color.png",
                      _carColorController,
                    ),
                    _buildCarSettingInput(
                      "Car Kind",
                      "assets/images/password_icon.png",
                      _carKindController,
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
      String title, String iconPath, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF01122A),
          border: Border.all(color: Colors.grey, width: 3),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
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
