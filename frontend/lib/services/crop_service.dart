import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class CropService {
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
      final Uri url = Uri.parse('${ApiConstants.cropAdvisorUrl}/recommend');

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
          .timeout(const Duration(seconds: 10));

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

        return 'Crop recommendation generated successfully. Please review your land details.';
      }

      // ========================================================
      // BACKEND ERROR - USER FRIENDLY
      // ========================================================

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final dynamic message = decoded['message'];

          if (message != null && message.toString().trim().isNotEmpty) {
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
        return 'Please ensure all land and crop fields are filled in correctly.';
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return 'Session expired. Please log in again to access the Crop Advisor.';
      }

      return 'Unable to retrieve recommendation right now. Please check your network connection and try again.';
    } on http.ClientException catch (e) {
      debugPrint('Crop Advisor Client Error: $e');
      return 'Unable to reach Agrii AI server. Please verify your connection.';
    } on FormatException catch (e) {
      debugPrint('Crop Advisor JSON Error: $e');
      return 'The server response was unexpected. Please try again.';
    } catch (e) {
      debugPrint('Crop Advisor Exception: $e');
      return 'Request timed out or could not connect. Please try again.';
    }
  }
}
