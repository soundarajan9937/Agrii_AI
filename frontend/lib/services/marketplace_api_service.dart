import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

class MarketplaceApiService {
  // =====================================================
  // GET AUTH HEADERS
  // =====================================================

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final headers = <String, String>{
      "Accept": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // =====================================================
  // GET APPROVED PRODUCTS
  // USER MARKETPLACE
  // =====================================================

  Future<List<dynamic>> getProducts() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse(ApiConstants.productUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data["products"] ?? [];
        }
        return [];
      }

      throw Exception("Failed to load products: ${response.statusCode}");
    } catch (e) {
      debugPrint("❌ GET PRODUCTS ERROR: $e");
      rethrow;
    }
  }

  // =====================================================
  // GET LOGGED-IN FARMER'S PRODUCTS
  // =====================================================

  Future<List<dynamic>> getMyProducts() async {
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.productUrl}/my";
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data["products"] ?? [];
        }
        return [];
      }

      throw Exception("Failed to load my products: ${response.statusCode}");
    } catch (e) {
      debugPrint("❌ GET MY PRODUCTS ERROR: $e");
      rethrow;
    }
  }

  // =====================================================
  // ADD PRODUCT
  // FARMER
  // =====================================================

  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String category,
    required String price,
    required String quantity,
    required String unit,
    required String seller,
    required String location,
    required String description,
    File? image,
  }) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiConstants.productUrl),
      );

      request.headers.addAll(headers);

      request.fields["name"] = name.trim();
      request.fields["category"] = category.trim();
      request.fields["description"] = description.trim();
      request.fields["price"] = price.trim();
      request.fields["quantity"] = quantity.trim();
      request.fields["unit"] = unit.trim();
      request.fields["seller"] = seller.trim();
      request.fields["location"] = location.trim();

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return {"success": true, "message": data["message"] ?? "Product uploaded!"};
      }

      return {
        "success": false,
        "message": data["message"] ?? "Upload failed (${response.statusCode})"
      };
    } catch (e) {
      debugPrint("❌ ADD PRODUCT ERROR: $e");
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // =====================================================
  // UPDATE PRODUCT
  // FARMER
  // =====================================================

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String category,
    required String price,
    required String quantity,
    required String unit,
    required String seller,
    required String location,
    required String description,
    File? image,
  }) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        "PUT",
        Uri.parse("${ApiConstants.productUrl}/$id"),
      );

      request.headers.addAll(headers);

      request.fields["name"] = name.trim();
      request.fields["category"] = category.trim();
      request.fields["description"] = description.trim();
      request.fields["price"] = price.trim();
      request.fields["quantity"] = quantity.trim();
      request.fields["unit"] = unit.trim();
      request.fields["seller"] = seller.trim();
      request.fields["location"] = location.trim();

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );
      }

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ UPDATE PRODUCT ERROR: $e");
      return false;
    }
  }

  // =====================================================
  // DELETE PRODUCT
  // FARMER
  // =====================================================

  Future<bool> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.productUrl}/$id";
      final response = await http.delete(Uri.parse(url), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ DELETE PRODUCT ERROR: $e");
      return false;
    }
  }
}
