import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class TrackingService {
  static Future<String?> _getToken() async => (await SharedPreferences.getInstance()).getString("token");

  static Future<Map<String, dynamic>?> getOrderLocation(String orderId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.trackingUrl}/order/$orderId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("TRACKING ERROR : $e");
      return null;
    }
  }

  static Future<bool> updateLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.trackingUrl}/order/$orderId/location"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("LOCATION UPDATE ERROR : $e");
      return false;
    }
  }

  static Future<bool> updateDeliveryStatus({required String orderId, required String status}) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.trackingUrl}/order/$orderId/status"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELIVERY STATUS ERROR : $e");
      return false;
    }
  }

  static Future<List<dynamic>> getTrackingHistory(String orderId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.trackingUrl}/order/$orderId/history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["history"] is List) return data["history"];
      }
      return [];
    } catch (e) {
      debugPrint("TRACKING HISTORY ERROR : $e");
      return [];
    }
  }
}
