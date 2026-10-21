import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/agri_resource_model.dart';
import '../models/agri_resource_order_model.dart';

class AgriResourceService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? prefs.getString("adminToken");
    return {
      "Authorization": "Bearer $token",
    };
  }

  // Farmer: Add Resource
  Future<bool> addResource({
    required String name,
    required String category,
    required String sellerName,
    required double price,
    required String phoneNumber,
    required File image,
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest("POST", Uri.parse("${ApiConstants.agriResourceUrl}/add"));
      request.headers.addAll(headers);

      request.fields["name"] = name;
      request.fields["category"] = category;
      request.fields["sellerName"] = sellerName;
      request.fields["price"] = price.toString();
      request.fields["phoneNumber"] = phoneNumber;
      if (description != null) request.fields["description"] = description;

      request.files.add(await http.MultipartFile.fromPath("image", image.path));

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // User/Farmer: Get Approved Resources
  Future<List<AgriResourceModel>> getApprovedResources() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.agriResourceUrl}/approved"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['resources'];
        return list.map((item) => AgriResourceModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Farmer: Get My Resources
  Future<List<AgriResourceModel>> getMyResources() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.agriResourceUrl}/my-resources"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['resources'];
        return list.map((item) => AgriResourceModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // User: Place Order
  Future<bool> placeOrder({
    required String buyerName,
    required String resourceId,
    required String sellerId,
    required double price,
    required String paymentMethod,
    required String buyerPhone,
    required String deliveryAddress,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final response = await http.post(
        Uri.parse("${ApiConstants.agriResourceUrl}/order/place"),
        headers: headers,
        body: jsonEncode({
          "buyerName": buyerName,
          "resourceId": resourceId,
          "sellerId": sellerId,
          "price": price,
          "paymentMethod": paymentMethod,
          "buyerPhone": buyerPhone,
          "deliveryAddress": deliveryAddress,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Farmer: Get Received Orders
  Future<List<AgriResourceOrderModel>> getFarmerOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.agriResourceUrl}/farmer-orders"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['orders'];
        return list.map((item) => AgriResourceOrderModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // User: Get My Orders
  Future<List<AgriResourceOrderModel>> getUserOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("${ApiConstants.agriResourceUrl}/user-orders"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['orders'];
        return list.map((item) => AgriResourceOrderModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Farmer: Accept Order
  Future<bool> acceptOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse("${ApiConstants.agriResourceUrl}/order/accept/$orderId"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // User: Cancel Order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse("${ApiConstants.agriResourceUrl}/order/cancel/$orderId"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Farmer: Delete Resource
  Future<bool> deleteResource(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse("${ApiConstants.agriResourceUrl}/delete/$id"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Farmer: Update Resource
  Future<bool> updateResource({
    required String id,
    required String name,
    required String category,
    required double price,
    required String phoneNumber,
    File? image,
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest("PUT", Uri.parse("${ApiConstants.agriResourceUrl}/update/$id"));
      request.headers.addAll(headers);

      request.fields["name"] = name;
      request.fields["category"] = category;
      request.fields["price"] = price.toString();
      request.fields["phoneNumber"] = phoneNumber;
      if (description != null) request.fields["description"] = description;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath("image", image.path));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
