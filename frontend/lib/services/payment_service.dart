import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class PaymentService {
  static Future<String?> _getToken() async => (await SharedPreferences.getInstance()).getString("token");

  static Future<Map<String, dynamic>?> createPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse("${ApiConstants.paymentUrl}/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "orderId": orderId,
          "amount": amount,
          "paymentMethod": paymentMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("PAYMENT ERROR : $e");
      return null;
    }
  }

  static Future<bool> createCashOnDelivery({required String orderId, required double amount}) async {
    final result = await createPayment(orderId: orderId, amount: amount, paymentMethod: "Cash on Delivery");
    return result?["success"] == true;
  }

  static Future<List<dynamic>> getPaymentHistory() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.paymentUrl}/history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["payments"] is List) return data["payments"];
      }
      return [];
    } catch (e) {
      debugPrint("PAYMENT HISTORY ERROR : $e");
      return [];
    }
  }
}
