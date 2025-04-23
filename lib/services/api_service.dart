import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:road_helperr/models/user_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://81.10.91.96:8132';

  // Get token from shared preferences
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Login API
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        return {
          'error':
              'فشل تسجيل الدخول: ${errorBody['message'] ?? 'خطأ غير معروف'} (كود الخطأ: ${response.statusCode})'
        };
      }
    } catch (e) {
      if (e is http.ClientException) {
        return {
          'error':
              'فشل الاتصال بالخادم: ${e.message}. تأكد من صحة عنوان الخادم والبورت'
        };
      }
      return {'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Send OTP API
  static Future<Map<String, dynamic>> sendOTP(String email) async {
    if (!await _checkConnectivity()) {
      return {
        'success': false,
        'error':
            'No internet connection. Please check your connection and try again'
      };
    }

    try {
      final requestData = {'email': email};
      print('Sending OTP request to: $baseUrl/otp/send');
      print('Request data: ${jsonEncode(requestData)}');
      print(
          'Request headers: {"Content-Type": "application/json", "Accept": "application/json"}');

      final response = await http.post(
        Uri.parse('$baseUrl/otp/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully'
        };
      } else if (response.statusCode == 404) {
        // إذا كان البريد الإلكتروني غير موجود
        return {
          'success': false,
          'error': 'This email is not registered in our system'
        };
      } else if (response.statusCode == 400) {
        // إذا كان هناك خطأ في تنسيق البريد الإلكتروني
        return {'success': false, 'error': 'Invalid email format'};
      } else {
        // أي خطأ آخر من الخادم
        return {
          'success': false,
          'error':
              responseData['message'] ?? 'Server error. Please try again later'
        };
      }
    } catch (e) {
      print('Error in sendOTP: $e');
      if (e is http.ClientException) {
        return {
          'success': false,
          'error':
              'Connection error. Please check your internet connection and try again'
        };
      }
      return {
        'success': false,
        'error':
            'An unexpected error occurred while sending OTP. Please try again'
      };
    }
  }

  // Send OTP Without Verification (for signup only)
  static Future<Map<String, dynamic>> sendOTPWithoutVerification(
      String email) async {
    if (!await _checkConnectivity()) {
      return {
        'success': false,
        'error':
            'No internet connection. Please check your connection and try again'
      };
    }

    try {
      final requestData = {'email': email};
      print(
          'Sending OTP without verification request to: $baseUrl/otp/send-without-verification');
      print('Request data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/otp/send-without-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully'
        };
      } else if (response.statusCode == 400) {
        return {'success': false, 'error': 'Invalid email format'};
      } else {
        return {
          'success': false,
          'error':
              responseData['message'] ?? 'Server error. Please try again later'
        };
      }
    } catch (e) {
      print('Error in sendOTPWithoutVerification: $e');
      if (e is http.ClientException) {
        return {
          'success': false,
          'error':
              'Connection error. Please check your internet connection and try again'
        };
      }
      return {
        'success': false,
        'error':
            'An unexpected error occurred while sending OTP. Please try again'
      };
    }
  }

  // Register API - Updated to verify OTP first
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData, String otp) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      // First verify the OTP
      final String email = userData['email'];
      print('Verifying OTP before registration for email: $email');
      print('OTP being verified: $otp');

      final verifyResult = await verifyOTP(email, otp);
      print('OTP verification result: $verifyResult');

      // If OTP verification failed, return the error immediately
      if (!verifyResult.containsKey('success') ||
          verifyResult['success'] != true) {
        return {
          'error': 'فشل التحقق من رمز OTP. يرجى التأكد من الرمز وإعادة المحاولة'
        };
      }

      // Only proceed with registration if OTP verification was successful
      print('OTP verified successfully, proceeding with registration');
      print('Registration data being sent: $userData');

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
          'message': 'تم التسجيل بنجاح'
        };
      } else {
        final errorBody = json.decode(response.body);
        return {
          'error':
              'فشل التسجيل: ${errorBody['message'] ?? 'خطأ غير معروف'} (كود الخطأ: ${response.statusCode})'
        };
      }
    } catch (e) {
      print('Error during registration process: $e');
      if (e is http.ClientException) {
        return {
          'error':
              'فشل الاتصال بالخادم: ${e.message}. تأكد من صحة عنوان الخادم والبورت'
        };
      }
      return {'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Verify OTP API - Improved with better error handling
  static Future<Map<String, dynamic>> verifyOTP(
      String email, String otp) async {
    if (!await _checkConnectivity()) {
      return {'error': 'لا يوجد اتصال بالإنترنت'};
    }

    try {
      print('Verifying OTP request to: $baseUrl/otp/verify');
      print('Data being sent: email=$email, otp=$otp');

      final response = await http.post(
        Uri.parse('$baseUrl/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      try {
        final responseData = jsonDecode(response.body);
        print('Decoded response: $responseData');

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'تم التحقق بنجاح'
          };
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          return {'error': responseData['message'] ?? 'رمز التحقق غير صحيح'};
        } else {
          return {
            'error': 'حدث خطأ في التحقق من الرمز (${response.statusCode})'
          };
        }
      } catch (e) {
        print('Error decoding response: $e');
        return {'error': 'تنسيق استجابة غير صالح من الخادم'};
      }
    } catch (e) {
      print('Error in verifyOTP: $e');
      return {'error': 'حدث خطأ أثناء التحقق من الرمز: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      // Check connectivity first
      if (!await _checkConnectivity()) {
        print('No internet connection available');
        return {
          'success': false,
          'exists': false,
          'message': 'No internet connection',
        };
      }

      print('Checking email existence for: $email');
      print('Sending request to: $baseUrl/api/check-email');

      final response = await http.post(
        Uri.parse('$baseUrl/api/check-email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Decoded response data: $data');

          return {
            'success': true,
            'exists': data['exists'] ?? false,
            'message': data['message'] ?? 'Email check completed',
          };
        } catch (e) {
          print('Error decoding response: $e');
          return {
            'success': false,
            'exists': false,
            'message': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'exists': false,
          'message': 'This email is not registered in the system',
        };
      } else {
        print('Server returned error status: ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'exists': false,
            'message':
                errorData['message'] ?? 'Failed to check email existence',
          };
        } catch (e) {
          return {
            'success': false,
            'exists': false,
            'message':
                'Failed to check email existence (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('Error in checkEmailExists: $e');
      if (e is http.ClientException) {
        return {
          'success': false,
          'exists': false,
          'message': 'Connection error: ${e.message}',
        };
      }
      return {
        'success': false,
        'exists': false,
        'message': 'An error occurred while checking email: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      print('Sending reset password request to: $baseUrl/api/reset-password');
      print('Data being sent: {"email": "$email", "password": "$newPassword"}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': newPassword,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح'
        };
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage =
            errorData['message'] ?? 'فشل في إعادة تعيين كلمة المرور';

        // تحسين رسائل الخطأ
        if (response.statusCode == 404) {
          errorMessage = 'البريد الإلكتروني غير مسجل في النظام';
        } else if (response.statusCode == 400) {
          errorMessage = 'كلمة المرور الجديدة غير صالحة';
        } else if (response.statusCode == 500) {
          errorMessage = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
        }

        return {'error': errorMessage};
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      if (e is http.ClientException) {
        return {
          'error':
              'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى'
        };
      }
      return {
        'error':
            'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى'
      };
    }
  }

  // Update user's location
  static Future<void> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update location');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  // Get nearby users
  static Future<List<UserLocation>> getNearbyUsers({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/nearby-users?latitude=$latitude&longitude=$longitude&radius=$radius'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserLocation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch nearby users');
      }
    } catch (e) {
      throw Exception('Error fetching nearby users: $e');
    }
  }
}
