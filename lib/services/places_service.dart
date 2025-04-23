import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:road_helperr/utils/text_strings.dart';

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _apiKey =
      'AIzaSyDGm9ZQELEZjPCOQWx2lxOOu5DDElcLc4Y'; // استبدل هذا بمفتاح API الخاص بك

  // البحث عن الأماكن القريبة
  static Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radius,
    required List<String> types,
  }) async {
    try {
      final typesString = types.join('|');
      final url =
          '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$typesString&key=$_apiKey';

      print('🔍 Places API Request:');
      print('URL: $url');
      print('Types: $types');
      print('Location: $latitude, $longitude');
      print('Radius: $radius meters');

      final response = await http.get(Uri.parse(url));

      print('📡 Places API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
          print('✅ Found ${results.length} places');
          return results;
        } else {
          print('❌ API Error: ${data['status']}');
          print('Error Message: ${data['error_message']}');
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching nearby places: $e');
      return [];
    }
  }

  // الحصول على تفاصيل مكان معين
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url =
          '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,geometry,rating,opening_hours,photos&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // الحصول على صورة مكان معين
  static String getPlacePhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  // تحويل نوع الفلتر إلى نوع Places API
  static String getPlaceType(String filterType) {
    switch (filterType) {
      case TextStrings.homeGas:
        return 'gas_station';
      case TextStrings.homePolice:
        return 'police';
      case TextStrings.homeFire:
        return 'fire_station';
      case TextStrings.homeHospital:
        return 'hospital';
      case TextStrings.homeMaintenance:
        return 'car_repair';
      case TextStrings.homeWinch:
        return 'tow_truck';
      default:
        print('❌ Unknown filter type: $filterType');
        return '';
    }
  }
}
