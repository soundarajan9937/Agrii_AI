import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CropService {
  // ==========================================================
  // BACKEND URL
  // ==========================================================
  //
  // Android Emulator:
  // http://10.0.2.2:5000
  //
  // Physical Android phone:
  // http://YOUR_COMPUTER_IP:5000
  //
  // Flutter Web on same computer:
  // http://localhost:5000
  // ==========================================================
  static const String _baseUrl = "http://10.253.175.78:5000";

  // ==========================================================
  // GET AI CROP RECOMMENDATION
  // ==========================================================

  static Future<String> getAIRecommendation({
    required String soil,
    required String season,
    required String duration,
    required String area,
    required String previousCrop,
  }) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/api/crop-advisor/recommend');

      debugPrint('======================================');
      debugPrint('AGRII AI CROP ADVISOR');
      debugPrint('Request URL: $url');
      debugPrint('Soil: $soil');
      debugPrint('Season: $season');
      debugPrint('Duration: $duration');
      debugPrint('Area: $area');
      debugPrint('Previous Crop: $previousCrop');
      debugPrint('======================================');

      final http.Response response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'soil': soil,
              'season': season,
              'duration': duration,
              'area': area,
              'previousCrop': previousCrop,
            }),
          )
          .timeout(const Duration(seconds: 40));

      debugPrint('Agrii AI Backend Status: ${response.statusCode}');

      debugPrint('Agrii AI Backend Response: ${response.body}');

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] == true) {
            final dynamic recommendation = decoded['recommendation'];

            if (recommendation != null &&
                recommendation.toString().trim().isNotEmpty) {
              return recommendation.toString().trim();
            }
          }
        }

        return 'The AI connected successfully, but no recommendation was returned.';
      }

      // ========================================================
      // BACKEND ERROR
      // ========================================================

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final dynamic message = decoded['message'];
          final dynamic error = decoded['error'];

          if (message != null && message.toString().trim().isNotEmpty) {
            if (error != null && error.toString().trim().isNotEmpty) {
              return '${message.toString()}\n\n${error.toString()}';
            }

            return message.toString();
          }
        }
      } catch (_) {
        // Response was not JSON.
      }

      // ========================================================
      // STATUS-SPECIFIC ERRORS
      // ========================================================

      if (response.statusCode == 400) {
        return 'Invalid crop advisor request. Please check the entered details.';
      }

      if (response.statusCode == 401) {
        return 'Authentication is required. Please login again.';
      }

      if (response.statusCode == 403) {
        return 'You do not have permission to use the Crop Advisor.';
      }

      if (response.statusCode == 404) {
        return 'Crop Advisor API was not found. Please check your backend route.';
      }

      if (response.statusCode == 500) {
        return 'The Agrii AI server encountered an error. Please check the backend and Gemini API configuration.';
      }

      if (response.statusCode == 502) {
        return 'Gemini AI is currently unavailable. Please try again later.';
      }

      return 'Unable to get crop recommendation. Server returned status ${response.statusCode}.';
    } on http.ClientException catch (e) {
      debugPrint('Crop Advisor Client Error: $e');

      return 'Unable to connect to the Agrii AI server. Please check your backend address and network connection.';
    } on FormatException catch (e) {
      debugPrint('Crop Advisor JSON Error: $e');

      return 'The Agrii AI server returned an invalid response.';
    } catch (e) {
      debugPrint('Crop Advisor Exception: $e');

      return 'Unable to connect to Agrii AI. Please check your internet connection and try again.';
    }
  }
}
