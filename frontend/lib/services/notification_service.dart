import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationService {
  // ==========================================================
  // GET HEADERS
  // ==========================================================
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ==========================================================
  // GET ALL NOTIFICATIONS
  // ==========================================================
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.notificationUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['notifications'] ?? [];
        return list.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("GET NOTIFICATIONS ERROR: $e");
      return [];
    }
  }

  // ==========================================================
  // GET UNREAD COUNT
  // ==========================================================
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("${ApiConstants.notificationUrl}/unread-count"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ==========================================================
  // MARK AS READ
  // ==========================================================
  Future<bool> markAsRead(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("${ApiConstants.notificationUrl}/$id/read"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================
  Future<bool> deleteNotification(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse("${ApiConstants.notificationUrl}/$id"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
