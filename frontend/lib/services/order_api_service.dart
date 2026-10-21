import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class OrderApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      debugPrint("ORDER API: Using Token: $token");
    } else {
      debugPrint("ORDER API: WARNING - No Token Found");
    }

    return headers;
  }

  // Create Order (User)
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final headers = await _getHeaders();

      debugPrint("ORDER API: POST ${ApiConstants.orderUrl}");
      debugPrint("ORDER API: BODY ${jsonEncode(orderData)}");

      final response = await http.post(
        Uri.parse(ApiConstants.orderUrl),
        headers: headers,
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: 15));

      debugPrint("ORDER API: STATUS ${response.statusCode}");
      debugPrint("ORDER API: RESPONSE ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "Order placed successfully", "order": data["order"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Server error (${response.statusCode})"};
      }
    } catch (e) {
      debugPrint("ORDER API: ERROR $e");
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // Get User Orders
  Future<List<dynamic>> getUserOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.orderUrl}/user"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["orders"] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Farmer Orders
  Future<List<dynamic>> getFarmerOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.orderUrl}/farmer"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["orders"] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get All Orders (Admin)
  Future<List<dynamic>> getAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("adminToken") ?? prefs.getString("token");
      final response = await http.get(
        Uri.parse("${ApiConstants.orderUrl}/admin/all"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["orders"] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Cancel Order (User)
  Future<bool> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse("${ApiConstants.orderUrl}/$orderId/cancel"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Accept Order (Farmer)
  Future<bool> acceptOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse("${ApiConstants.orderUrl}/$orderId/accept"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update Status (Farmer)
  Future<bool> updateStatus(String orderId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("${ApiConstants.orderUrl}/$orderId/status"),
        headers: headers,
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
