import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AdminService {
  // ==========================================
  // ADMIN LOGIN
  // ==========================================

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.adminUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      debugPrint("========== ADMIN LOGIN ==========");
      debugPrint("Status : ${response.statusCode}");
      debugPrint("Body   : ${response.body}");
      debugPrint("=================================");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString("adminToken", data["token"] ?? "");
          await prefs.setString("adminId", data["admin"]?["_id"] ?? "");
          await prefs.setString("adminName", data["admin"]?["name"] ?? "");
          await prefs.setString("adminEmail", data["admin"]?["email"] ?? "");

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint("ADMIN LOGIN ERROR : $e");
      return false;
    }
  }

  static Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString("adminToken");

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("adminToken");
    await prefs.remove("adminId");
    await prefs.remove("adminName");
    await prefs.remove("adminEmail");
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==========================================
  // DASHBOARD STATISTICS
  // ==========================================

  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/dashboard"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("ADMIN DASHBOARD : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      debugPrint("DASHBOARD ERROR : $e");
      return null;
    }
  }

  // ==========================================
  // GET USERS
  // ==========================================

  static Future<List<dynamic>> getUsers() async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("USERS : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["users"] is List) return data["users"];
      }
      return [];
    } catch (e) {
      debugPrint("GET USERS ERROR : $e");
      return [];
    }
  }

  // ==========================================
  // GET PRODUCTS
  // ==========================================

  static Future<List<dynamic>> getProducts() async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/products"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("PRODUCTS : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["products"] is List) return data["products"];
      }
      return [];
    } catch (e) {
      debugPrint("GET PRODUCTS ERROR : $e");
      return [];
    }
  }

  // ==========================================
  // APPROVE PRODUCT
  // ==========================================

  static Future<bool> approveProduct(String productId) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.adminUrl}/products/$productId/approve"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("APPROVE ERROR : $e");
      return false;
    }
  }

  // ==========================================
  // REJECT PRODUCT
  // ==========================================

  static Future<bool> rejectProduct(String productId) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.adminUrl}/products/$productId/reject"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("REJECT ERROR : $e");
      return false;
    }
  }

  // ==========================================
  // GET ORDERS
  // ==========================================

  static Future<List<dynamic>> getOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.adminUrl}/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["orders"] is List) return data["orders"];
      }
      return [];
    } catch (e) {
      debugPrint("GET ORDERS ERROR : $e");
      return [];
    }
  }

  // ==========================================
  // UPDATE ORDER STATUS
  // ==========================================

  static Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse("${ApiConstants.adminUrl}/orders/$orderId/status"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("UPDATE ORDER ERROR : $e");
      return false;
    }
  }
}
