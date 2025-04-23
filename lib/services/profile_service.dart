import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_data.dart';

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
        ...profileData.toJson(),
      };

      final requestBody = json.encode(requestData);

      print('=== UPDATE PROFILE REQUEST ===');
      print('URL: $baseUrl/data');
      print('Method: PUT');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      print('Body: $requestBody');
      print('============================');

      final response = await http.put(
        Uri.parse('$baseUrl/data'),
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
}
