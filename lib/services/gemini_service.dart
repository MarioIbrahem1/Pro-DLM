import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiChatMessage {
  final String text;
  final bool isUser;

  GeminiChatMessage({required this.text, required this.isUser});
}

class GeminiService {
  // قائمة بمفاتيح API المتعددة
  static const List<String> _apiKeys = [
    'AIzaSyCXFfiCkJL5VF3ABb3tIeJahAh2N0DoJgA', // المفتاح الأساسي
    'AIzaSyDNjuCNTRdwPMQZqIRtdk18QliFEUL3FGY', // مفتاح احتياطي 1
    'AIzaSyBppSCjheGWXIMQAHJo3rhISPCWHYG_wug', // مفتاح احتياطي 2
  ];

  // مؤشر للمفتاح الحالي المستخدم
  static int _currentKeyIndex = 0;

  // متغير لتخزين حالة تبديل المفتاح
  static bool _apiKeySwitched = false;

  // الحصول على مفتاح API الحالي
  static String get _currentApiKey => _apiKeys[_currentKeyIndex];

  // تهيئة Gemini بالمفتاح الحالي
  static void _initGemini() {
    Gemini.init(apiKey: _currentApiKey, enableDebugging: true);
  }

  // التبديل إلى المفتاح التالي
  static bool switchToNextApiKey() {
    if (_currentKeyIndex < _apiKeys.length - 1) {
      _currentKeyIndex++;
      _apiKeySwitched = true;
      debugPrint('Switched to API key ${_currentKeyIndex + 1}');
      _initGemini(); // تهيئة Gemini بالمفتاح الجديد
      return true;
    }
    return false; // لا توجد مفاتيح أخرى متاحة
  }

  // التحقق مما إذا تم تبديل المفتاح
  static bool get wasApiKeySwitched => _apiKeySwitched;

  // إعادة تعيين حالة تبديل المفتاح
  static void resetApiKeySwitchFlag() {
    _apiKeySwitched = false;
  }

  // For text-only queries with chat history
  static Future<String?> sendQuery({
    required List<Map<String, dynamic>> data,
    required String userQuery,
    required List<GeminiChatMessage> chatHistory,
    String? systemContext,
    String? responseFormat,
  }) async {
    // إعادة تعيين حالة تبديل المفتاح
    resetApiKeySwitchFlag();

    // تهيئة Gemini
    _initGemini();

    // بناء الاستعلام
    final prompt = _buildSystemPrompt(
      items: data,
      contextDescription: systemContext,
      responseInstructions: responseFormat,
    );

    // بناء سجل المحادثة
    final String conversationHistory = _buildConversationHistory(chatHistory);

    // إنشاء النص الكامل للاستعلام
    final String fullPrompt =
        "$prompt\n\nسجل المحادثة السابقة:\n$conversationHistory\n\nالسؤال الحالي: $userQuery";

    // محاولة إرسال الاستعلام باستخدام المفتاح الحالي
    String? result = await _trySendQuery(fullPrompt);

    // إذا فشلت المحاولة الأولى، حاول استخدام المفاتيح البديلة
    if (result == null || result.contains("حدث خطأ أثناء الاتصال بالخادم")) {
      // محاولة استخدام مفتاح بديل
      if (switchToNextApiKey()) {
        // إضافة رسالة اعتذار
        result = await _trySendQuery(fullPrompt);

        // إذا نجحت المحاولة الثانية، أضف رسالة اعتذار
        if (result != null && !result.contains("حدث خطأ")) {
          result = "عذراً على التأخير، كان هناك مشكلة فنية تم حلها.\n\n$result";
        }
      }
    }

    return result;
  }

  // دالة مساعدة لمحاولة إرسال الاستعلام
  static Future<String?> _trySendQuery(String fullPrompt) async {
    try {
      // استخدام طريقة prompt التي تعتبر أكثر موثوقية
      final gemini = Gemini.instance;
      final response = await gemini.prompt(
        parts: [Part.text(fullPrompt)],
      );

      if (response == null) {
        debugPrint('Empty response from Gemini API');
        return "عذراً، لم أستطع الحصول على إجابة من الخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.";
      }

      final output = response.output;
      debugPrint('Gemini Response: $output');
      return output;
    } catch (e) {
      debugPrint('Gemini Error with key $_currentKeyIndex: ${e.toString()}');
      return "حدث خطأ أثناء الاتصال بالخادم: ${e.toString()}. يرجى المحاولة مرة أخرى.";
    }
  }

  // For image and text queries with chat history
  static Future<String?> sendImageQuery({
    required List<Map<String, dynamic>> data,
    required String userQuery,
    required File imageFile,
    required List<GeminiChatMessage> chatHistory,
    String? systemContext,
    String? responseFormat,
  }) async {
    // إعادة تعيين حالة تبديل المفتاح
    resetApiKeySwitchFlag();

    // تهيئة Gemini
    _initGemini();

    // بناء الاستعلام
    final prompt = _buildSystemPrompt(
      items: data,
      contextDescription: systemContext,
      responseInstructions: responseFormat,
    );

    // بناء سجل المحادثة
    final String conversationHistory = _buildConversationHistory(chatHistory);

    // إنشاء النص الكامل للاستعلام
    final String textPrompt =
        "$prompt\n\nسجل المحادثة السابقة:\n$conversationHistory\n\nالسؤال الحالي: $userQuery";

    // محاولة إرسال الاستعلام باستخدام المفتاح الحالي
    String? result = await _trySendImageQuery(textPrompt, imageFile);

    // إذا فشلت المحاولة الأولى، حاول استخدام المفاتيح البديلة
    if (result == null || result.contains("حدث خطأ")) {
      // محاولة استخدام مفتاح بديل
      if (switchToNextApiKey()) {
        // محاولة ثانية باستخدام المفتاح البديل
        result = await _trySendImageQuery(textPrompt, imageFile);

        // إذا نجحت المحاولة الثانية، أضف رسالة اعتذار
        if (result != null && !result.contains("حدث خطأ")) {
          result = "عذراً على التأخير، كان هناك مشكلة فنية تم حلها.\n\n$result";
        }
      }
    }

    return result;
  }

  // دالة مساعدة لمحاولة إرسال استعلام مع صورة
  static Future<String?> _trySendImageQuery(
      String textPrompt, File imageFile) async {
    try {
      final gemini = Gemini.instance;
      final imageBytes = imageFile.readAsBytesSync();

      // استخدام طريقة prompt مع Parts للتعامل مع النص والصورة
      final response = await gemini.prompt(
        parts: [
          Part.text(textPrompt),
          Part.bytes(imageBytes),
        ],
      );

      if (response == null) {
        debugPrint('Empty response from Gemini API for image query');
        return "عذراً، لم أستطع الحصول على إجابة من الخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.";
      }

      final output = response.output;
      debugPrint('Gemini Image Response: $output');
      return output;
    } catch (e) {
      debugPrint(
          'Gemini Image Error with key $_currentKeyIndex: ${e.toString()}');
      return "حدث خطأ أثناء معالجة الصورة: ${e.toString()}. يرجى المحاولة مرة أخرى.";
    }
  }

  // Helper method to build conversation history string
  static String _buildConversationHistory(List<GeminiChatMessage> chatHistory) {
    final buffer = StringBuffer();

    for (final message in chatHistory) {
      final role = message.isUser ? 'المستخدم' : 'المساعد';
      buffer.write('$role: ${message.text}\n');
    }

    return buffer.toString();
  }

  static String _buildSystemPrompt({
    required List<Map<String, dynamic>> items,
    String? contextDescription,
    String? responseInstructions,
  }) {
    final buffer = StringBuffer();

    buffer.write(contextDescription ?? 'Analyze this data:\n');

    for (final item in items) {
      item.forEach((key, value) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            buffer.write('• ${key.toUpperCase()}_${i + 1}: ${value[i]}\n');
          }
        } else {
          buffer.write('• ${key.toUpperCase()}: $value\n');
        }
      });
    }

    buffer.write(responseInstructions ?? '\nRespond helpfully.');
    return buffer.toString();
  }
}
