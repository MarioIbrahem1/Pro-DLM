import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart';
import '../../../utils/app_colors.dart';
import '../ai_welcome_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';

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

  // Variables to store filter options
  Map<String, bool>? _filters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get filter options from HomeScreen
    _filters = ModalRoute.of(context)!.settings.arguments as Map<String, bool>?;
    print("Received Filters: $_filters"); // Print received filters
    _getCurrentLocation();
  }

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
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
    // Convert filters to Google Places API types
    List<String> selectedTypes = _filters!.entries
        .where((entry) => entry.value) // Only selected filters
        .map((entry) {
          switch (entry.key) {
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
        })
        .where((type) => type.isNotEmpty) // Remove empty types
        .toList();

    if (selectedTypes.isEmpty) {
      print("No filters selected!"); // Print if no filters are selected
      return; // No filters selected
    }

    // Build the API request URL
    String types = selectedTypes.join('|'); // Combine types with "|"
    String apiKey =
        'AIzaSyDrP9YA-D4xFrLi-v1klPXvtoEuww6kmBo'; // Replace with your API key
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=$types&key=$apiKey";

    // Make the API request
    print("API URL: $url"); // Print the API URL

    // Send the request
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("API Response: $data"); // Print the API response
      _updateMapWithPlaces(data['results']);
    } else {
      print("Error fetching data!");
    }
  }

  // Function to update the map with nearby places
  void _updateMapWithPlaces(List<dynamic> places) {
    Set<Marker> markers = {};

    for (var place in places) {
      double lat = place['geometry']['location']['lat'];
      double lng = place['geometry']['location']['lng'];
      String name = place['name'];

      markers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        target: _currentLocation, // Use current location
        zoom: 15.0, // Adjust zoom level as needed
      ),
      markers: _markers, // Add markers to the map
      myLocationEnabled: true, // Show user's location on the map
      myLocationButtonEnabled: true, // Show button to center on user's location
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
