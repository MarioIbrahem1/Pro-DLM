import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart';
import '../../../utils/app_colors.dart';
import '../ai_welcome_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'package:road_helperr/services/notification_service.dart';
import 'dart:async';

// Import new components
import 'map_screen_components/map_controller.dart';
import 'map_screen_components/map_navigation.dart';
import 'map_screen_components/place_details_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = "map";
  const MapScreen({super.key});
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  // Map controller
  late GoogleMapController mapController;

  // State variables
  LatLng _currentLocation = const LatLng(30.0444, 31.2357);
  bool _isLoading = true;
  int _selectedIndex = 1;
  Set<Marker> _markers = {};

  // Timers
  Timer? _locationUpdateTimer;
  Timer? _usersUpdateTimer;

  // Map controller instance
  late MapController _mapController;

  @override
  void initState() {
    super.initState();

    // Initialize map controller with callbacks
    _mapController = MapController(
      onLoadingChanged: (isLoading) {
        if (mounted) {
          setState(() {
            _isLoading = isLoading;
          });
        }
      },
      onMarkersChanged: (markers) {
        if (mounted) {
          setState(() {
            _markers = markers;
          });
        }
      },
      onLocationChanged: (location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
        }
      },
      onError: (title, message) {
        if (mounted) {
          NotificationService.showError(
            context: context,
            title: title,
            message: message,
          );
        }
      },
      onPlaceSelected: (details) {
        if (mounted) {
          PlaceDetailsBottomSheet.show(context, details);
        }
      },
    );

    _initializeMap();
    _startLocationUpdates();
    _startUsersUpdates();
  }

  Future<void> _initializeMap() async {
    await _mapController.initializeMap();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _usersUpdateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    _mapController.startLocationUpdates();
  }

  void _startUsersUpdates() {
    _mapController.startUsersUpdates();
  }

  // Removed unused methods

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtener los argumentos
    final arguments = ModalRoute.of(context)?.settings.arguments;

    // Verificar si los argumentos son del nuevo formato (mapa con filtros y coordenadas)
    if (arguments is Map<String, dynamic>) {
      // Extraer los filtros
      final filters = arguments['filters'] as Map<String, bool>?;
      if (filters != null) {
        _mapController.setFilters(filters);
      }

      // Extraer las coordenadas
      final latitude = arguments['latitude'] as double?;
      final longitude = arguments['longitude'] as double?;

      if (latitude != null && longitude != null) {
        // Actualizar la ubicación actual
        setState(() {
          _currentLocation = LatLng(latitude, longitude);
        });

        // Actualizar la ubicación en el controlador del mapa
        _mapController.updateCurrentLocation(_currentLocation);

        // Mover la cámara a la ubicación actual cuando esté disponible
        // Esto se ejecutará después de que el mapa se haya creado
        Future.delayed(Duration.zero, () {
          try {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _currentLocation, zoom: 15.0),
              ),
            );
          } catch (e) {
            debugPrint('Error al mover la cámara: $e');
          }
        });
      }
    }
    // Compatibilidad con el formato antiguo (solo filtros)
    else if (arguments is Map<String, bool>) {
      _mapController.setFilters(arguments);
    }
  }

  // Methods now handled by the MapController class

  // ----------   BUILD UI  ----------
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF01122A),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.getBackgroundColor(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppColors.getBackgroundColor(context),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.getBackgroundColor(context),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
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
      zoomControlsEnabled: true,
      compassEnabled: true,
      onCameraMove: (CameraPosition position) {
        _mapController.onCameraMove(position);
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _mapController.setMapController(controller);
  }

  Widget _buildMaterialNavBar(
    BuildContext context,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return MapNavigation.buildMaterialNavBar(
      context: context,
      iconSize: iconSize,
      navBarHeight: navBarHeight,
      isDesktop: isDesktop,
      selectedIndex: _selectedIndex,
      onTap: (index) => _handleNavigation(context, index),
    );
  }

  Widget _buildCupertinoNavBar(
    BuildContext context,
    double iconSize,
    double navBarHeight,
    bool isDesktop,
  ) {
    return MapNavigation.buildCupertinoNavBar(
      context: context,
      iconSize: iconSize,
      navBarHeight: navBarHeight,
      isDesktop: isDesktop,
      selectedIndex: _selectedIndex,
      onTap: (index) => _handleNavigation(context, index),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
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
