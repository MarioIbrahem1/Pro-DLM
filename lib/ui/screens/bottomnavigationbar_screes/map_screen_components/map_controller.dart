import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:road_helperr/models/user_location.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/services/places_service.dart';
import 'package:road_helperr/services/notification_service.dart';

/// Controller class to manage map logic and state
class MapController {
  // Map controller
  GoogleMapController? _mapController;

  // Current location
  LatLng _currentLocation = const LatLng(30.0444, 31.2357); // Cairo default

  // Markers
  Set<Marker> _markers = {};
  Set<Marker> _userMarkers = {};

  // Filters
  Map<String, bool>? _filters;

  // Timers
  Timer? _locationUpdateTimer;
  Timer? _usersUpdateTimer;

  // Loading state
  bool _isLoading = true;

  // Getters
  LatLng get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;

  // Callbacks
  final Function(bool) onLoadingChanged;
  final Function(Set<Marker>) onMarkersChanged;
  final Function(LatLng) onLocationChanged;
  final Function(String, String) onError;
  final Function(Map<String, dynamic>) onPlaceSelected;

  MapController({
    required this.onLoadingChanged,
    required this.onMarkersChanged,
    required this.onLocationChanged,
    required this.onError,
    required this.onPlaceSelected,
  });

  /// Initialize map and location
  Future<void> initializeMap() async {
    try {
      await _getCurrentLocation();
      onLoadingChanged(false);
    } catch (e) {
      onError('Location Error', 'Could not initialize map: $e');
      onLoadingChanged(false);
    }
  }

  /// Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Set filters and update places
  void setFilters(Map<String, bool>? filters) {
    _filters = filters;
    if (_filters != null) {
      _fetchNearbyPlaces(_currentLocation.latitude, _currentLocation.longitude);
    }
  }

  /// Start periodic location updates
  void startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateUserLocation();
    });
  }

  /// Start periodic nearby users updates
  void startUsersUpdates() {
    _usersUpdateTimer?.cancel();
    _usersUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchNearbyUsers();
    });
  }

  /// Update user location to server
  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      await ApiService.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  /// Fetch nearby users
  Future<void> _fetchNearbyUsers() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<UserLocation> nearbyUsers = await ApiService.getNearbyUsers(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
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

      _userMarkers = userMarkers;
      _updateMarkers();
    } catch (e) {
      debugPrint('Error fetching nearby users: $e');
    }
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        onLoadingChanged(false);
        onError(
          'Location Error',
          'Could not get your current location. Please check your GPS signal and try again.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          onLoadingChanged(false);
          onError(
            'Location Error',
            'Location permission denied. Please allow location access.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        onLoadingChanged(false);
        onError(
          'Location Error',
          'Location permission permanently denied. Please enable it from settings.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      ).timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      onLocationChanged(_currentLocation);

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 15.0),
          ),
        );
      }

      if (_filters != null) {
        await _fetchNearbyPlaces(position.latitude, position.longitude);
      }
    } catch (e) {
      onLoadingChanged(false);
      onError(
        'Location Error',
        'Could not get your current location. Please try again.',
      );
    }
  }

  /// Fetch nearby places based on filters
  Future<void> _fetchNearbyPlaces(double latitude, double longitude) async {
    try {
      if (_filters == null || _filters!.isEmpty) return;

      // التأكد من استخدام الموقع الحالي الفعلي
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // استخدام الموقع الحالي الفعلي بدلاً من الموقع المرسل
      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;

      // تحديث الموقع الحالي
      _currentLocation = LatLng(latitude, longitude);
      onLocationChanged(_currentLocation);

      // تحريك الكاميرا إلى الموقع الحالي
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 15.0),
          ),
        );
      }

      // Debug: Print filters and location
      debugPrint('Filters: $_filters');
      debugPrint('Current Location: $latitude, $longitude');

      // تحسين أسماء الفلاتر وإضافة كلمات مفتاحية
      Map<String, Map<String, dynamic>> filterMapping = {
        'Hospital': {
          'type': 'hospital',
          'keyword': 'hospital مستشفى',
          'hue': BitmapDescriptor.hueRed,
        },
        'Police': {
          'type': 'police',
          'keyword': 'police قسم شرطة',
          'hue': BitmapDescriptor.hueBlue,
        },
        'Maintenance center': {
          'type': 'car_repair',
          'keyword': 'car repair auto service مركز صيانة ورشة',
          'hue': BitmapDescriptor.hueOrange,
        },
        'Winch': {
          'type': 'car_dealer', // تغيير من tow_truck لأنه غير معترف به في API
          'keyword': 'tow truck winch ونش سطحة',
          'hue': BitmapDescriptor.hueYellow,
        },
        'Gas Station': {
          'type': 'gas_station',
          'keyword': 'gas station fuel محطة وقود بنزين',
          'hue': BitmapDescriptor.hueGreen,
        },
        'Fire Station': {
          'type': 'fire_station',
          'keyword': 'fire station مطافي',
          'hue': BitmapDescriptor.hueViolet,
        },
      };

      List<Map<String, dynamic>> selectedFilters = [];
      _filters!.forEach((key, value) {
        if (value && filterMapping.containsKey(key)) {
          selectedFilters.add(filterMapping[key]!);
        }
      });

      // Debug: Print selected filters
      debugPrint('Selected filters: $selectedFilters');

      if (selectedFilters.isEmpty) return;

      Set<Marker> placeMarkers = {};

      // زيادة نصف قطر البحث للحصول على نتائج أكثر
      const double searchRadius = 10000; // 10 كيلومتر بدلاً من 5

      // معالجة كل نوع فلتر على حدة
      for (var filter in selectedFilters) {
        final type = filter['type'] as String;
        final keyword = filter['keyword'] as String;
        final markerHue = filter['hue'] as double;

        debugPrint('Fetching places for type: $type, keyword: $keyword');

        try {
          // استخدام الميزات الجديدة في PlacesService
          final places = await PlacesService.searchNearbyPlaces(
            latitude: latitude,
            longitude: longitude,
            radius: searchRadius,
            types: [type],
            keyword: keyword,
            fetchAllPages: true, // الحصول على جميع الصفحات
          );

          debugPrint(
              'Found ${places.length} places for type: $type, keyword: $keyword');

          for (var place in places) {
            try {
              final lat =
                  (place['geometry']['location']['lat'] as num).toDouble();
              final lng =
                  (place['geometry']['location']['lng'] as num).toDouble();
              final name = place['name'] as String? ?? 'Unknown Place';
              final placeId =
                  place['place_id'] as String? ?? DateTime.now().toString();
              final vicinity = place['vicinity'] as String? ?? '';

              debugPrint('Adding marker for place: $name at $lat,$lng');

              placeMarkers.add(
                Marker(
                  markerId: MarkerId(placeId),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                    title: name,
                    snippet: vicinity,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
                  onTap: () async {
                    try {
                      final details =
                          await PlacesService.getPlaceDetails(placeId);
                      if (details != null) {
                        _handlePlaceSelected(details);
                      }
                    } catch (e) {
                      debugPrint('Error getting place details: $e');
                      onError(
                        'Error',
                        'Could not load place details. Please try again.',
                      );
                    }
                  },
                ),
              );
            } catch (e) {
              debugPrint('Error processing place: $e');
              continue;
            }
          }
        } catch (e) {
          debugPrint('Error fetching places for type $type: $e');
        }
      }

      debugPrint('Total markers: ${placeMarkers.length}');

      // تحديث العلامات
      _markers = placeMarkers;
      _updateMarkers();
    } catch (e) {
      debugPrint('Error in _fetchNearbyPlaces: $e');
      onError(
        'Error',
        'Failed to fetch nearby places. Please try again.',
      );
    }
  }

  /// Update markers by combining place markers and user markers
  void _updateMarkers() {
    final combinedMarkers = {..._markers, ..._userMarkers};
    onMarkersChanged(combinedMarkers);
  }

  /// Handle place selection
  void _handlePlaceSelected(Map<String, dynamic> details) {
    // Call the callback to show place details in UI
    onPlaceSelected(details);
  }

  /// Update camera position
  void onCameraMove(CameraPosition position) {
    _currentLocation = position.target;
    onLocationChanged(_currentLocation);
  }

  /// Update current location manually
  void updateCurrentLocation(LatLng location) {
    _currentLocation = location;
    onLocationChanged(_currentLocation);

    // Actualizar los marcadores basados en la nueva ubicación
    if (_filters != null && _filters!.isNotEmpty) {
      _fetchNearbyPlaces(location.latitude, location.longitude);
    }
  }

  /// Dispose resources
  void dispose() {
    _locationUpdateTimer?.cancel();
    _usersUpdateTimer?.cancel();
    _mapController?.dispose();
  }
}
