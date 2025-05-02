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
    String? keyword,
    String? pageToken,
    bool fetchAllPages = true,
  }) async {
    try {
      // إذا كان هناك pageToken، يجب الانتظار قليلاً قبل استخدامه (حسب توثيق Google)
      if (pageToken != null) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // بناء URL الأساسي
      String url =
          '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&key=$_apiKey';

      // إضافة types إذا كانت متوفرة
      if (types.isNotEmpty) {
        final typesString = types.join('|');
        url += '&type=$typesString';
      }

      // إضافة keyword إذا كان متوفراً
      if (keyword != null && keyword.isNotEmpty) {
        url += '&keyword=${Uri.encodeComponent(keyword)}';
      }

      // إضافة pageToken إذا كان متوفراً
      if (pageToken != null) {
        url += '&pagetoken=$pageToken';
      }

      print('🔍 Places API Request:');
      print('URL: $url');
      print('Types: $types');
      print('Keyword: $keyword');
      print('Location: $latitude, $longitude');
      print('Radius: $radius meters');
      print('Page Token: $pageToken');

      // إجراء طلب HTTP
      final response = await http.get(Uri.parse(url));

      print('📡 Places API Response:');
      print('Status Code: ${response.statusCode}');

      // التحقق من صحة الاستجابة
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // التحقق من حالة API
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
          print(
              '✅ Found ${results.length} places for types: $types, keyword: $keyword');

          // طباعة النتيجة الأولى للتصحيح
          if (results.isNotEmpty) {
            print(
                'First result: ${results[0]['name']} at ${results[0]['geometry']['location']}');
          }

          // التحقق من وجود صفحة تالية
          final nextPageToken = data['next_page_token'];

          // إذا كان هناك صفحة تالية وتم طلب جميع الصفحات
          if (nextPageToken != null && fetchAllPages) {
            print('📄 Next page token found: $nextPageToken');

            // الحصول على نتائج الصفحة التالية
            final nextPageResults = await searchNearbyPlaces(
              latitude: latitude,
              longitude: longitude,
              radius: radius,
              types: types,
              keyword: keyword,
              pageToken: nextPageToken,
              fetchAllPages: fetchAllPages,
            );

            // دمج النتائج
            results.addAll(nextPageResults);
            print('📊 Total results after pagination: ${results.length}');
          }

          return results;
        } else {
          print('❌ API Error: ${data['status']}');
          if (data.containsKey('error_message')) {
            print('Error Message: ${data['error_message']}');
          }

          // إرجاع قائمة فارغة في حالة خطأ API
          return [];
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in searchNearbyPlaces: $e');
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
  static Map<String, dynamic> getPlaceTypeAndKeyword(String filterType) {
    switch (filterType) {
      case TextStrings.homeGas:
        return {
          'type': 'gas_station',
          'keyword': 'gas station fuel محطة وقود بنزين',
        };
      case TextStrings.homePolice:
        return {
          'type': 'police',
          'keyword': 'police قسم شرطة',
        };
      case TextStrings.homeFire:
        return {
          'type': 'fire_station',
          'keyword': 'fire station مطافي',
        };
      case TextStrings.homeHospital:
        return {
          'type': 'hospital',
          'keyword': 'hospital مستشفى',
        };
      case TextStrings.homeMaintenance:
        return {
          'type': 'car_repair',
          'keyword': 'car repair auto service مركز صيانة ورشة',
        };
      case TextStrings.homeWinch:
        return {
          'type': 'car_dealer',
          'keyword': 'tow truck winch ونش سطحة',
        };
      default:
        print('❌ Unknown filter type: $filterType');
        return {
          'type': '',
          'keyword': '',
        };
    }
  }

  // للتوافق مع الكود القديم
  static String getPlaceType(String filterType) {
    return getPlaceTypeAndKeyword(filterType)['type'];
  }
}
