import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String userId;
  final String userName;
  final LatLng position;
  final String? profileImage;
  final bool isOnline;

  UserLocation({
    required this.userId,
    required this.userName,
    required this.position,
    this.profileImage,
    this.isOnline = true,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId'],
      userName: json['userName'],
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      profileImage: json['profileImage'],
      isOnline: json['isOnline'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'profileImage': profileImage,
      'isOnline': isOnline,
    };
  }
}
