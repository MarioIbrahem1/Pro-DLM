import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for handling polylines
class PolylineUtils {
  /// Decode an encoded polyline string into a list of LatLng points
  static List<LatLng> decodePolyline(String encoded) {
    if (encoded.isEmpty) {
      debugPrint('Warning: Empty polyline string provided');
      return [];
    }

    try {
      List<LatLng> points = [];
      int index = 0, len = encoded.length;
      int lat = 0, lng = 0;

      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);

        if (index > len) {
          debugPrint('Warning: Polyline decoding error - index out of bounds');
          break;
        }

        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        // Check if we have enough characters left for longitude
        if (index >= len) {
          debugPrint(
              'Warning: Polyline decoding error - incomplete coordinate pair');
          break;
        }

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);

        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        // Validate coordinates before adding
        if (lat / 1E5 >= -90 &&
            lat / 1E5 <= 90 &&
            lng / 1E5 >= -180 &&
            lng / 1E5 <= 180) {
          points.add(LatLng(lat / 1E5, lng / 1E5));
        } else {
          debugPrint(
              'Warning: Invalid coordinates in polyline: ${lat / 1E5}, ${lng / 1E5}');
        }
      }

      debugPrint('Decoded ${points.length} points from polyline');
      return points;
    } catch (e) {
      debugPrint('Error decoding polyline: $e');
      return [];
    }
  }

  /// Calculate the distance between two LatLng points in meters
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    double lat1 = point1.latitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  /// Format distance in meters to a human-readable string
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} م';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
    }
  }

  /// Format duration in seconds to a human-readable string
  static String formatDuration(int durationInSeconds) {
    if (durationInSeconds < 60) {
      return '$durationInSeconds ثانية';
    } else if (durationInSeconds < 3600) {
      int minutes = (durationInSeconds / 60).floor();
      return '$minutes دقيقة';
    } else {
      int hours = (durationInSeconds / 3600).floor();
      int minutes = ((durationInSeconds % 3600) / 60).floor();
      return '$hours ساعة ${minutes > 0 ? ' و $minutes دقيقة' : ''}';
    }
  }
}
