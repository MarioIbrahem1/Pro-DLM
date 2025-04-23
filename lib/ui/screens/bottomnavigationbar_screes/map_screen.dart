import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart';
import '../../../utils/app_colors.dart';
import '../ai_welcome_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'package:road_helperr/services/notification_service.dart';
import 'package:road_helperr/models/user_location.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/services/places_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = "map";

  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(30.0444, 31.2357); // Default to Cairo
  bool _isLoading = true; // To show loading state
  int _selectedIndex = 1; // Moved _selectedIndex here
  Set<Marker> _markers = {}; // Markers to show on the map
  Set<Marker> _userMarkers = {};

  // Variables to store filter options
  Map<String, bool>? _filters;
  Timer? _locationUpdateTimer;
  Timer? _usersUpdateTimer;

  // إضافة متغير لتخزين الفلتر المحدد
  String _selectedFilter = 'Hospital';

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _startUsersUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _usersUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Update user's location every 30 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateUserLocation();
    });
  }

  void _startUsersUpdates() {
    // Update other users' locations every 10 seconds
    _usersUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchNearbyUsers();
    });
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      // Update user's location in the backend
      await ApiService.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  Future<void> _fetchNearbyUsers() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<UserLocation> nearbyUsers = await ApiService.getNearbyUsers(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000, // 5km radius
      );

      Set<Marker> userMarkers = {};
      for (var user in nearbyUsers) {
        userMarkers.add(
          Marker(
            markerId: MarkerId(user.userId),
            position: user.position,
            infoWindow: InfoWindow(
              title: user.userName,
              snippet: user.isOnline ? 'Online' : 'Offline',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              user.isOnline
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
          ),
        );
      }

      setState(() {
        _userMarkers = userMarkers;
        _markers = {..._markers, ..._userMarkers};
      });
    } catch (e) {
      print('Error fetching nearby users: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استقبال الفلاتر من الشاشة السابقة
    final receivedFilters =
        ModalRoute.of(context)?.settings.arguments as Map<String, bool>?;
    if (receivedFilters != null) {
      setState(() {
        _filters = receivedFilters;
      });
      print(
          "Received filters in Map Screen: $_filters"); // للتأكد من استلام الفلاتر
      _getCurrentLocation(); // تحديث الخريطة بناءً على الفلاتر الجديدة
    }
  }

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      NotificationService.showError(
        context: context,
        title: 'Location Services Disabled',
        message: 'Please enable location services to use this feature.',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        NotificationService.showError(
          context: context,
          title: 'Location Permission Denied',
          message: 'Please grant location permission to use this feature.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      NotificationService.showError(
        context: context,
        title: 'Location Permission Permanently Denied',
        message: 'Please enable location permission in your device settings.',
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false; // Stop loading
    });

    // Fetch nearby places based on filters
    if (_filters != null) {
      _fetchNearbyPlaces(position.latitude, position.longitude);
    }
  }

  // Function to fetch nearby places using Google Places API
  Future<void> _fetchNearbyPlaces(double latitude, double longitude) async {
    try {
      print('🔍 Starting to fetch nearby places');

      if (_filters == null || _filters!.isEmpty) {
        print("❌ No filters available!");
        return;
      }

      // تحويل الفلاتر إلى أنواع Google Places
      List<String> selectedTypes = [];
      _filters!.forEach((key, value) {
        if (value) {
          // إذا كان الفلتر مفعل
          String placeType = '';
          switch (key) {
            case 'Hospital':
              placeType = 'hospital';
              break;
            case 'Police':
              placeType = 'police';
              break;
            case 'Maintenance center':
              placeType = 'car_repair';
              break;
            case 'Winch':
              placeType = 'car_dealer';
              break;
            case 'Gas Station':
              placeType = 'gas_station';
              break;
            case 'Fire Station':
              placeType = 'fire_station';
              break;
          }
          if (placeType.isNotEmpty) {
            selectedTypes.add(placeType);
          }
        }
      });

      print(
          'Selected place types for API: $selectedTypes'); // للتأكد من الأنواع المرسلة للـ API

      if (selectedTypes.isEmpty) {
        print("❌ No valid place types found!");
        return;
      }

      // جلب الأماكن القريبة لكل نوع على حدة للحصول على نتائج أفضل
      Set<Marker> allMarkers = {};

      for (String type in selectedTypes) {
        final places = await PlacesService.searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          types: [type],
        );

        print('Found ${places.length} places for type: $type');

        for (var place in places) {
          try {
            final lat =
                (place['geometry']['location']['lat'] as num).toDouble();
            final lng =
                (place['geometry']['location']['lng'] as num).toDouble();
            final name = place['name'] as String? ?? 'Unknown Place';
            final placeId =
                place['place_id'] as String? ?? DateTime.now().toString();

            // تحديد لون الماركر بناءً على نوع المكان
            double markerHue;
            switch (type) {
              case 'hospital':
                markerHue = BitmapDescriptor.hueRed;
                break;
              case 'police':
                markerHue = BitmapDescriptor.hueBlue;
                break;
              case 'car_repair':
                markerHue = BitmapDescriptor.hueOrange;
                break;
              case 'car_dealer':
                markerHue = BitmapDescriptor.hueYellow;
                break;
              case 'gas_station':
                markerHue = BitmapDescriptor.hueGreen;
                break;
              case 'fire_station':
                markerHue = BitmapDescriptor.hueViolet;
                break;
              default:
                markerHue = BitmapDescriptor.hueRed;
            }

            allMarkers.add(
              Marker(
                markerId: MarkerId(placeId),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
                onTap: () async {
                  try {
                    final details =
                        await PlacesService.getPlaceDetails(placeId);
                    if (details != null && mounted) {
                      _showPlaceDetails(details);
                    }
                  } catch (e) {
                    print('Error getting place details: $e');
                    if (mounted) {
                      NotificationService.showError(
                        context: context,
                        title: 'Error',
                        message:
                            'Could not load place details. Please try again.',
                      );
                    }
                  }
                },
              ),
            );
          } catch (e) {
            print('Error adding marker: $e');
            continue;
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers = allMarkers;
        });
      }
    } catch (e) {
      print('❌ Error fetching nearby places: $e');
      if (mounted) {
        NotificationService.showError(
          context: context,
          title: 'Error',
          message: 'Failed to fetch nearby places. Please try again.',
        );
      }
    }
  }

  void _showPlaceDetails(Map<String, dynamic> details) {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.borderField.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderField.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.borderField.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Open Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              details['name'] as String? ?? 'Unknown Place',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.labelTextField,
                              ),
                            ),
                          ),
                          if (details['opening_hours'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (details['opening_hours']['open_now']
                                            as bool?) ??
                                        false
                                    ? AppColors.basicButton.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (details['opening_hours']['open_now']
                                              as bool?) ??
                                          false
                                      ? AppColors.basicButton
                                      : Colors.red,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                (details['opening_hours']['open_now']
                                            as bool?) ??
                                        false
                                    ? 'Open'
                                    : 'Closed',
                                style: TextStyle(
                                  color: (details['opening_hours']['open_now']
                                              as bool?) ??
                                          false
                                      ? AppColors.labelTextField
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Rating
                      if (details['rating'] != null)
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              double rating =
                                  (details['rating'] as num).toDouble();
                              return Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : index < rating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: AppColors.signAndRegister,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${(details['rating'] as num).toDouble()}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    AppColors.labelTextField.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Address
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppColors.labelTextField.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              details['formatted_address'] as String? ??
                                  'No address available',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    AppColors.labelTextField.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.directions,
                            label: 'Directions',
                            onTap: () {
                              try {
                                final lat = (details['geometry']['location']
                                        ['lat'] as num)
                                    .toDouble();
                                final lng = (details['geometry']['location']
                                        ['lng'] as num)
                                    .toDouble();
                                final url =
                                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                                launch(url);
                              } catch (e) {
                                print('Error opening directions: $e');
                              }
                            },
                          ),
                          if (details['formatted_phone_number'] != null)
                            _buildActionButton(
                              icon: Icons.phone,
                              label: 'Call',
                              onTap: () {
                                try {
                                  launch(
                                      'tel:${details['formatted_phone_number']}');
                                } catch (e) {
                                  print('Error making call: $e');
                                }
                              },
                            ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            onTap: () {
                              // Implement share functionality
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error showing place details: $e');
      NotificationService.showError(
        context: context,
        title: 'Error',
        message: 'Could not display place details. Please try again.',
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.basicButton.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.basicButton.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.labelTextField, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.labelTextField,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    // تطبيق النمط المخصص على الخريطة
    String mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    mapController.setMapStyle(mapStyle);
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
          'Map Screen',
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
      backgroundColor: Colors.yellow,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : _buildBody(context, size, constraints, titleSize, isDesktop),
      bottomNavigationBar: _buildMaterialNavBar(
        context,
        iconSize,
        navBarHeight,
        isDesktop,
      ),
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
          'Map Screen',
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
      backgroundColor: Colors.yellow,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator()) // Show loading
                  : _buildBody(
                      context, size, constraints, titleSize, isDesktop),
            ),
            _buildCupertinoNavBar(
              context,
              iconSize,
              navBarHeight,
              isDesktop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Size size,
    BoxConstraints constraints,
    double titleSize,
    bool isDesktop,
  ) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _currentLocation,
        zoom: 15.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
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
        index: _selectedIndex, // Use _selectedIndex from State
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
        currentIndex: _selectedIndex, // Use _selectedIndex from State
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
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

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
