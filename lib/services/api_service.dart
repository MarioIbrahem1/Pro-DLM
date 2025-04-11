import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static const String baseUrl = 'http://81.10.91.96:8132';

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

  // Check Email Existence API - Real-time validation
  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // نتحقق من قيمة exists في الرد
        if (responseBody['exists'] == 1) {
          return {'exists': true, 'message': 'البريد الإلكتروني مسجل'};
        } else {
          return {
            'exists': false,
            'message': 'مفيش اكونت متسجل على الايميل ده'
          };
        }
      } else {
        return {'exists': false, 'message': 'مفيش اكونت متسجل على الايميل ده'};
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

  // OTP Send API
  static Future<Map<String, dynamic>> sendOTP(String email) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      // First check if email exists
      final checkResult = await checkEmailExists(email);

      if (checkResult.containsKey('error')) {
        return checkResult;
      }

      if (!checkResult['exists']) {
        return {'error': 'مفيش اكونت متسجل على الايميل ده'};
      }

      // If email exists, proceed with sending OTP
      final response = await http.post(
        Uri.parse('$baseUrl/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'تم إرسال رمز التحقق بنجاح'};
      } else {
        final errorBody = json.decode(response.body);
        return {
          'error':
              'فشل إرسال رمز التحقق: ${errorBody['message'] ?? 'خطأ غير معروف'} (كود الخطأ: ${response.statusCode})'
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

  // Register API
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        return {
          'error':
              'فشل التسجيل: ${errorBody['message'] ?? 'خطأ غير معروف'} (كود الخطأ: ${response.statusCode})'
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

  // Verify OTP API
  static Future<Map<String, dynamic>> verifyOTP(
      String email, String otp) async {
    if (!await _checkConnectivity()) {
      return {
        'error':
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        return {
          'error':
              'فشل التحقق من الرمز: ${errorBody['message'] ?? 'خطأ غير معروف'} (كود الخطأ: ${response.statusCode})'
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
}
