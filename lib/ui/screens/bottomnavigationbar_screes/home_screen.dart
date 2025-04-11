import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';
import 'notification_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;
  int pressCount = 0;
  Set<Marker> _markers = <Marker>{};

  final Map<String, bool> serviceStates = {
    TextStrings.homeGas: false,
    TextStrings.homePolice: false,
    TextStrings.homeFire: false,
    TextStrings.homeHospital: false,
    TextStrings.homeMaintenance: false,
    TextStrings.homeWinch: false,
  };
  double? currentLatitude;
  double? currentLongitude;

  // عندما يغير اليوزر حالة الفلتر
  void toggleFilter(String key, bool value) {
    setState(() {
      serviceStates[key] = value;
    });
    print("Filter changed: $key -> $value");
  }

  Future<void> getFilteredServices() async {
    // جمع الفلاتر المختارة من الخدمة
    List<String> selectedKeys = serviceStates.entries
        .where((entry) => entry.value) // اختار فقط الفلاتر المفعلة
        .map((entry) => entry.key)
        .toList();

    print("Selected filters: $selectedKeys"); // هنا هتشوف الفلاتر المرسلة

    // لو اليوزر ما اختاروش أي فلتر
    if (selectedKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one service!")),
      );
      return;
    }

    // بناء الرابط لإرسال الفلاتر إلى الـ API
    String placeTypes = selectedKeys.map((e) {
      switch (e) {
        case 'homeGas':
          return 'gas_station';
        case 'homePolice':
          return 'police';
        case 'homeFire':
          return 'fire_station';
        case 'homeHospital':
          return 'hospital';
        case 'homeMaintenance':
          return 'car_repair';
        case 'homeWinch':
          return 'tow_truck';
        default:
          return '';
      }
    }).join('|'); // دمج الفلاتر المختارة بفاصل "|"

    // ارسال الريكويست للـ API جوجل ماب
    var response = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$currentLatitude,$currentLongitude&radius=5000&type=$placeTypes&key=AIzaSyDrP9YA-D4xFrLi-v1klPXvtoEuww6kmBo",
      ),
    );

    // معالجة البيانات المسترجعة من الـ API
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Filtered Data: $data"); // هنا هتشوف الرد من الـ API
      // استخدم البيانات المسترجعة لعرضها في الخريطة
      _updateMapWithFilteredData(data);
    } else {
      print("Error fetching data!");
    }
  }

  // هنا دالة لتحديث الماب بالبيانات الجديدة بعد الفلترة
  void _updateMapWithFilteredData(var data) {
    // إظهار الأماكن التي تطابق الفلتر
    Set<Marker> filteredMarkers = <Marker>{};

    for (var result in data['results']) {
      var marker = Marker(
        markerId: MarkerId(result['place_id']),
        position: LatLng(result['geometry']['location']['lat'],
            result['geometry']['location']['lng']),
        infoWindow: InfoWindow(title: result['name']),
      );
      filteredMarkers.add(marker);
    }

    setState(() {
      // تحديث الـ markers في الخريطة
      _markers = filteredMarkers; // التأكد من أن _markers هو من نوع Set<Marker>
    });
  }

  int selectedServicesCount = 0;
  String location = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          location = "${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        location = "Location not available";
      });
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Warning'),
          content: const Text('Please select between 1 to 3 services.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMap(BuildContext context) {
    if (selectedServicesCount >= 1 && selectedServicesCount <= 3) {
      print("Selected Filters: $serviceStates"); // Print selected filters
      getFilteredServices();
      Navigator.pushNamed(
        context,
        MapScreen.routeName,
        arguments: serviceStates, // إرسال اختيارات الفلترة
      );
    } else {
      _showWarningDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = MediaQuery.of(context).size;
              final isTablet = constraints.maxWidth > 600;
              final isDesktop = constraints.maxWidth > 1200;

              double titleSize = size.width *
                  (isDesktop
                      ? 0.03
                      : isTablet
                          ? 0.04
                          : 0.055);
              double iconSize = size.width *
                  (isDesktop
                      ? 0.03
                      : isTablet
                          ? 0.04
                          : 0.05);
              double padding = size.width *
                  (isDesktop
                      ? 0.02
                      : isTablet
                          ? 0.03
                          : 0.04);

              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/home background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _buildScaffold(
                    context, constraints, size, titleSize, iconSize, padding),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, BoxConstraints constraints,
      Size size, double titleSize, double iconSize, double padding) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return _buildCupertinoScaffold(
          context, constraints, size, titleSize, iconSize, padding);
    } else {
      return _buildMaterialScaffold(
          context, constraints, size, titleSize, iconSize, padding);
    }
  }

  Widget _buildMaterialScaffold(
      BuildContext context,
      BoxConstraints constraints,
      Size size,
      double titleSize,
      double iconSize,
      double padding) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: iconSize * 1.2,
          ),
          onPressed: () {},
        ),
        title: Text(
          location,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/Ellipse 42.png'),
              radius: titleSize,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _buildBody(
            context, constraints, size, titleSize, iconSize, padding),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, iconSize),
    );
  }

  Widget _buildCupertinoScaffold(
      BuildContext context,
      BoxConstraints constraints,
      Size size,
      double titleSize,
      double iconSize,
      double padding) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.location,
            color: Colors.white,
            size: iconSize * 1.2,
          ),
          onPressed: () {},
        ),
        middle: Text(
          location,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontFamily: '.SF Pro Text',
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.all(padding),
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/images/Ellipse 42.png'),
            radius: titleSize,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBody(
                  context, constraints, size, titleSize, iconSize, padding),
              _buildBottomNavBar(context, iconSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints, Size size,
      double titleSize, double iconSize, double padding) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextStrings.homeGetYouBack,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize * 1.2,
              fontWeight: FontWeight.bold,
              fontFamily: isIOS ? '.SF Pro Text' : null,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.backGroundColor,
              borderRadius: BorderRadius.circular(isIOS ? 10 : 15),
            ),
            child: Column(
              children: [
                _buildServiceGrid(constraints, iconSize, titleSize, padding),
                SizedBox(height: size.height * 0.02),
                _buildGetServiceButton(context, size, titleSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BoxConstraints constraints, double iconSize,
      double titleSize, double padding) {
    final isDesktop = constraints.maxWidth > 1200;
    final isTablet = constraints.maxWidth > 600;

    return GridView.count(
      crossAxisCount: isDesktop
          ? 4
          : isTablet
              ? 3
              : 2,
      mainAxisSpacing: padding,
      crossAxisSpacing: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: serviceStates.entries.map((entry) {
        return ServiceCard(
          title: entry.key,
          icon: getServiceIcon(entry.key),
          isSelected: entry.value,
          iconSize: iconSize,
          fontSize: titleSize * 0.8,
          onToggle: (value) {
            setState(() {
              if (value) {
                if (selectedServicesCount < 3) {
                  serviceStates[entry.key] = value;
                  selectedServicesCount++;
                } else {
                  _showWarningDialog(context);
                }
              } else {
                serviceStates[entry.key] = value;
                selectedServicesCount--;
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildGetServiceButton(
      BuildContext context, Size size, double titleSize) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.06,
        child: CupertinoButton(
          color: AppColors.basicButton,
          borderRadius: BorderRadius.circular(8),
          onPressed: () => _navigateToMap(context),
          child: Text(
            TextStrings.homeGetYourService,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.basicButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _navigateToMap(context),
        child: Text(
          TextStrings.homeGetYourService,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, double iconSize) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isIOS) {
      return CupertinoTabBar(
        backgroundColor: AppColors.backGroundColor,
        activeColor: Colors.white,
        inactiveColor: Colors.white.withOpacity(0.6),
        height: iconSize * 3,
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
      );
    }

    return CurvedNavigationBar(
      backgroundColor: AppColors.cardColor,
      color: AppColors.backGroundColor,
      animationDuration: const Duration(milliseconds: 300),
      height: iconSize * 3 > 75.0 ? 75.0 : iconSize * 3,
      items: [
        Icon(Icons.home_outlined, size: iconSize, color: Colors.white),
        Icon(Icons.location_on_outlined, size: iconSize, color: Colors.white),
        Icon(Icons.textsms_outlined, size: iconSize, color: Colors.white),
        Icon(Icons.notifications_outlined, size: iconSize, color: Colors.white),
        Icon(Icons.person_2_outlined, size: iconSize, color: Colors.white),
      ],
      onTap: (index) => _handleNavigation(context, index),
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

  IconData getServiceIcon(String title) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    switch (title) {
      case TextStrings.homeGas:
        return isIOS ? CupertinoIcons.gauge : Icons.local_gas_station;
      case TextStrings.homePolice:
        return isIOS ? CupertinoIcons.shield_fill : Icons.local_police;
      case TextStrings.homeFire:
        return isIOS ? CupertinoIcons.flame_fill : Icons.fire_truck;
      case TextStrings.homeHospital:
        return isIOS ? CupertinoIcons.heart_fill : Icons.local_hospital;
      case TextStrings.homeMaintenance:
        return isIOS ? CupertinoIcons.wrench_fill : Icons.build;
      case TextStrings.homeWinch:
        return isIOS ? CupertinoIcons.car_fill : Icons.car_repair;
      default:
        return isIOS ? CupertinoIcons.question : Icons.help;
    }
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool> onToggle;
  final double iconSize;
  final double fontSize;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onToggle,
    required this.iconSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = constraints.maxWidth * 0.1;

        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.stackColorIsSelected
                : AppColors.stackColor,
            borderRadius: BorderRadius.circular(isIOS ? 15 : 20),
          ),
          child: Stack(
            children: [
              Positioned(
                top: padding,
                right: padding,
                child: Transform.scale(
                  scale: constraints.maxWidth / 200,
                  child: isIOS
                      ? CupertinoSwitch(
                          value: isSelected,
                          onChanged: onToggle,
                          activeColor: AppColors.backGroundColor,
                        )
                      : Switch(
                          value: isSelected,
                          onChanged: onToggle,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.backGroundColor,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.switchColor,
                        ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: iconSize,
                        color: isSelected
                            ? Colors.white
                            : AppColors.backGroundColor,
                      ),
                      SizedBox(height: padding / 2),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textStackColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: isIOS ? '.SF Pro Text' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
