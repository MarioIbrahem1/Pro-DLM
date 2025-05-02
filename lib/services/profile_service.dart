import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/profile_data.dart';
import 'package:http_parser/http_parser.dart'; // لازم يكون موجود
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final Position? position;
  final String? error;

  LocationResult({this.position, this.error});
}

class ProfileService {
  final String baseUrl = 'http://81.10.91.96:8132/api';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  Future<ProfileData> getProfileData(String email) async {
    try {
      print('=== GET PROFILE REQUEST ===');
      print('URL: $baseUrl/data');
      print('Method: POST');
      print('Headers: $headers');
      print('Body: ${jsonEncode({"email": email})}');
      print('========================');

      final response = await http.post(
        Uri.parse('$baseUrl/data'),
        headers: headers,
        body: jsonEncode({"email": email}),
      );

      print('=== GET PROFILE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==========================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final userData = jsonResponse['data']['user'];
          final carData = jsonResponse['data']['car'];

          // Format car data in a more readable way in Arabic
          final carInfo = 'السيارة: ${carData['carModel']}\n'
              'اللون: ${carData['carColor']}\n'
              'رقم اللوحة: ${carData['letters']} ${carData['plateNumber']}';

          return ProfileData(
            name: '${userData['firstName']} ${userData['lastName']}'.trim(),
            email: userData['email'],
            phone: userData['phone'],
            address: carInfo,
            carModel: carData['carModel'],
            carColor: carData['carColor'],
            plateNumber: '${carData['letters']} ${carData['plateNumber']}',
          );
        }
      }

      throw Exception('Failed to load profile data');
    } catch (e) {
      print('Error in getProfileData: $e');
      throw Exception('Failed to load profile data: $e');
    }
  }

  Future<void> updateProfileData(String email, ProfileData profileData) async {
    try {
      final Map<String, dynamic> requestData = {
        'email': email,
        'firstName': profileData.name.split(' ')[0],
        'lastName': profileData.name.split(' ').length > 1
            ? profileData.name.split(' ').sublist(1).join(' ')
            : '',
        'phone': profileData.phone,
        'carModel': profileData.carModel,
        'carColor': profileData.carColor,
        'plateNumber': profileData.plateNumber,
      };

      final requestBody = json.encode(requestData);

      print('=== UPDATE PROFILE REQUEST ===');
      print('URL: $baseUrl/updateuser');
      print('Method: PUT');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      print('Body: $requestBody');
      print('============================');

      final response = await http.put(
        Uri.parse('$baseUrl/updateuser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('=== UPDATE PROFILE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateProfileData: $e');
      throw Exception('Error updating profile data: $e');
    }
  }

  Future<String> uploadProfileImage(String email, File imageFile) async {
    try {
      print('=== UPLOAD IMAGE REQUEST ===');
      print('URL: $baseUrl/upload');
      print('Method: POST');
      print('Email: $email');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.fields['email'] = email;

      String ext = path.extension(imageFile.path).toLowerCase();
      String mimeType = ext == '.png' ? 'png' : 'jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', mimeType),
        ),
      );

      // Print all fields and files before sending
      print('Request fields: \\${request.fields}');
      print(
          'Request files: \\${request.files.map((f) => f.filename).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Upload response: \\${response.body}');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success' &&
          jsonResponse['image_url'] != null) {
        print('Image uploaded. URL: \\${jsonResponse['image_url']}');
        return jsonResponse['image_url'];
      }
      print('Upload failed. Response: \\${response.body}');
      throw Exception('Failed to upload profile image');
    } catch (e) {
      print('Error in uploadProfileImage: \\$e');
      throw Exception('Failed to upload profile image: \\$e');
    }
  }

  Future<String> getProfileImage(String email) async {
    try {
      print('=== GET PROFILE IMAGE REQUEST ===');
      print('URL: $baseUrl/images');
      print('Method: POST');
      print('Email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/images'),
        headers: headers,
        body: jsonEncode({'email': email}),
      );
      print('Get image response: \\${response.body}');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success' &&
          jsonResponse['image_url'] != null) {
        print('Fetched image URL: \\${jsonResponse['image_url']}');
        return jsonResponse['image_url'];
      }
      print('No image found for this user. Response: \\${response.body}');
      return '';
    } catch (e) {
      print('Error in getProfileImage: \\$e');
      return '';
    }
  }

  Future<void> checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<LocationResult> getCurrentLocation() async {
    try {
      // تحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(error: 'خدمة الموقع غير مفعلة. يرجى تفعيل GPS.');
      }

      // تحقق من الصلاحية
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
              error: 'تم رفض صلاحية الموقع. يرجى السماح للتطبيق.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
            error:
                'صلاحية الموقع مرفوضة بشكل دائم. يرجى تفعيلها من الإعدادات.');
      }

      // جلب الموقع
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LocationResult(position: position);
    } catch (e) {
      print('Location error: $e');
      return LocationResult(error: 'حدث خطأ أثناء جلب الموقع: $e');
    }
  }
}
