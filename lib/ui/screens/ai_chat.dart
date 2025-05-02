import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart'; // ✅ استيراد ImagePicker
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/home_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/notification_screen.dart';
import '../screens/bottomnavigationbar_screes/profile_screen.dart';
import 'package:road_helperr/utils/text_strings.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ استيراد permission_handler
import 'dart:io';

class AiChat extends StatefulWidget {
  static const String routeName = "ai chat";
  final int _selectedIndex = 2;

  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _hasCameraPermission = false;
  String? _tempImagePath;

  bool get _showWelcomeMessages => _messages.isEmpty;

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasCameraPermission = true;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;
        final viewInsets = MediaQuery.of(context).viewInsets;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

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

        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF01122A),
          appBar: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF01122A),
            title: Text(
              TextStrings.appBarAiChat,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
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
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                size: iconSize * 1.2,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xFF01122A),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: spacing / 2),
                        Image.asset(
                          'assets/images/ai.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: spacing / 2),
                        Expanded(
                          child: _showWelcomeMessages
                              ? const Column(
                                  children: [
                                    InfoCard(
                                      title: "Answer of your questions",
                                      subtitle:
                                          "( Just ask me anything you like )",
                                      isUserMessage: false,
                                      isWelcomeMessage: true,
                                    ),
                                    SizedBox(height: 8),
                                    InfoCard(
                                      title: "Available for you all day",
                                      subtitle:
                                          "( Feel free to ask me anytime )",
                                      isUserMessage: false,
                                      isWelcomeMessage: true,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: spacing * 0.3),
                                      child: InfoCard(
                                        title: message.message,
                                        subtitle: message.details,
                                        isUserMessage: message.isUserMessage,
                                        imagePath: message.imagePath,
                                        timestamp: message.timestamp,
                                        isWelcomeMessage: false,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: _buildChatInput(
                        context, size, titleSize, iconSize, platform),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: viewInsets.bottom == 0
              ? Container(
                  constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity),
                  child: CurvedNavigationBar(
                    backgroundColor: const Color(0xFF01122A),
                    color: const Color(0xFF1F3551),
                    buttonBackgroundColor: const Color(0xFF1F3551),
                    animationDuration: const Duration(milliseconds: 300),
                    height: 45,
                    index: 2,
                    items: [
                      Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.home
                              : Icons.home_outlined,
                          size: 15,
                          color: Colors.white),
                      Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.location
                              : Icons.location_on_outlined,
                          size: 15,
                          color: Colors.white),
                      Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.chat_bubble
                              : Icons.textsms_outlined,
                          size: 15,
                          color: Colors.white),
                      Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.bell
                              : Icons.notifications_outlined,
                          size: 15,
                          color: Colors.white),
                      Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.person
                              : Icons.person_2_outlined,
                          size: 15,
                          color: Colors.white),
                    ],
                    onTap: (index) => _handleNavigation(context, index),
                  ),
                )
              : null,
          resizeToAvoidBottomInset: true,
        );
      },
    );
  }

  Widget _buildChatInput(BuildContext context, Size size, double titleSize,
      double iconSize, TargetPlatform platform) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_tempImagePath != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_tempImagePath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: IconButton(
                      icon:
                          const Icon(Icons.cancel, color: Colors.red, size: 24),
                      onPressed: () {
                        setState(() {
                          _tempImagePath = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    minLines: 1,
                    style: TextStyle(
                      fontSize: titleSize * 0.8,
                      color: Colors.black,
                      fontFamily: platform == TargetPlatform.iOS
                          ? '.SF Pro Text'
                          : null,
                    ),
                    decoration: InputDecoration(
                      hintText: TextStrings.hintChatText,
                      hintStyle: TextStyle(
                        fontSize: titleSize * 0.8,
                        color: Colors.black54,
                        fontFamily: platform == TargetPlatform.iOS
                            ? '.SF Pro Text'
                            : null,
                      ),
                      filled: true,
                      fillColor:
                          isLightMode ? const Color(0xFFCCC9C9) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          platform == TargetPlatform.iOS
                              ? CupertinoIcons.camera
                              : Icons.camera_alt_outlined,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFF023A87)
                                  : const Color(0xFF296FF5),
                          size: iconSize,
                        ),
                        onPressed: _showCameraConfirmationDialog,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF023A87)
                      : const Color(0xFF296FF5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    platform == TargetPlatform.iOS
                        ? CupertinoIcons.arrow_right
                        : Icons.send,
                    color: Colors.white,
                    size: iconSize * 0.8,
                  ),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty || _tempImagePath != null) {
      setState(() {
        _messages.add(ChatMessage(
          message: message,
          details: "",
          isUserMessage: true,
          imagePath: _tempImagePath,
          timestamp: DateTime.now(),
        ));
        _messageController.clear();
        _tempImagePath = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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

  Future<void> _showCameraConfirmationDialog() async {
    if (_hasCameraPermission) {
      _pickImageFromCamera();
    } else {
      final status = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = status.isGranted;
      });
      if (status.isGranted) {
        _pickImageFromCamera();
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _tempImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error capturing image")),
      );
    }
  }
}

class ChatMessage {
  final String message;
  final String details;
  final bool isUserMessage;
  final String? imagePath;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.details,
    required this.isUserMessage,
    this.imagePath,
    required this.timestamp,
  });
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isUserMessage;
  final String? imagePath;
  final DateTime? timestamp;
  final bool isWelcomeMessage;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isUserMessage,
    this.imagePath,
    this.timestamp,
    required this.isWelcomeMessage,
  });

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUserMessage ? 50 : 8,
          right: isUserMessage ? 8 : 50,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isUserMessage
                    ? const Color(0xFF023A87)
                    : (isLightMode
                        ? const Color(0xFFE8E8E8)
                        : const Color(0xFF1F3551)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUserMessage ? 16 : 4),
                  bottomRight: Radius.circular(isUserMessage ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(imagePath!),
                          width: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                      if (title.isNotEmpty) const SizedBox(height: 8),
                    ],
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: isUserMessage
                              ? Colors.white
                              : (isLightMode ? Colors.black : Colors.white),
                        ),
                      ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUserMessage
                              ? Colors.white.withOpacity(0.7)
                              : (isLightMode ? Colors.black54 : Colors.white70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!isWelcomeMessage && timestamp != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
