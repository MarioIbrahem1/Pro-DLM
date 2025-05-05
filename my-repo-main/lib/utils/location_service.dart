// import 'package:geolocator/geolocator.dart';
//
// class LocationService {
//   Stream<Position> get positionStream => Geolocator.getPositionStream();
//
//   Future<void> checkLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//   }
//
//   Future<bool> isLocationServiceEnabled() async {
//     return await Geolocator.isLocationServiceEnabled();
//   }
// }
