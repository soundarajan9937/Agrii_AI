import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class DiseaseAIService {
  // ==========================================================
  // SINGLETON
  // ==========================================================

  DiseaseAIService._privateConstructor();

  static final DiseaseAIService instance =
      DiseaseAIService._privateConstructor();

  // ==========================================================
  // ANALYZE PLANT / LEAF IMAGE
  // ==========================================================
  //
  // Sends:
  //
  // POST /api/disease/upload
  //
  // Multipart field:
  //
  // image
  //
  // ==========================================================

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // ------------------------------------------------------
      // CHECK IMAGE EXISTS
      // ------------------------------------------------------

      if (!await imageFile.exists()) {
        return {"success": false, "message": "Selected image does not exist."};
      }

      // ------------------------------------------------------
      // CHECK FILE SIZE
      // ------------------------------------------------------

      final int fileSize = await imageFile.length();

      if (fileSize == 0) {
        return {"success": false, "message": "Selected image is empty."};
      }

      // ------------------------------------------------------
      // API URL
      // ------------------------------------------------------

      final Uri url = Uri.parse("${ApiConstants.diseaseUrl}/upload");

      // ------------------------------------------------------
      // CREATE MULTIPART REQUEST
      // ------------------------------------------------------

      final request = http.MultipartRequest("POST", url);

      // ------------------------------------------------------
      // ACCEPT JSON RESPONSE
      // ------------------------------------------------------

      request.headers.addAll({"Accept": "application/json"});

      // ------------------------------------------------------
      // ADD IMAGE
      // ------------------------------------------------------

      final multipartFile = await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
      );

      request.files.add(multipartFile);

      // ------------------------------------------------------
      // SEND REQUEST
      // ------------------------------------------------------

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      // ------------------------------------------------------
      // READ RESPONSE
      // ------------------------------------------------------

      final responseBody = await streamedResponse.stream.bytesToString();

      // ------------------------------------------------------
      // DEBUG
      // ------------------------------------------------------

      print("========================================");

      print("🌿 DISEASE DETECTION RESPONSE");

      print("Status: ${streamedResponse.statusCode}");

      print(responseBody);

      print("========================================");

      // ------------------------------------------------------
      // EMPTY RESPONSE
      // ------------------------------------------------------

      if (responseBody.trim().isEmpty) {
        return {
          "success": false,
          "message": "Server returned an empty response.",
        };
      }

      // ------------------------------------------------------
      // CHECK HTML RESPONSE
      // ------------------------------------------------------

      final trimmedBody = responseBody.trim();

      if (trimmedBody.startsWith("<!DOCTYPE") ||
          trimmedBody.startsWith("<html") ||
          trimmedBody.startsWith("<HTML")) {
        return {
          "success": false,
          "message":
              "Server returned an HTML response instead of JSON. "
              "Check the disease API URL and backend.",
        };
      }

      // ------------------------------------------------------
      // DECODE JSON
      // ------------------------------------------------------

      dynamic decoded;

      try {
        decoded = jsonDecode(responseBody);
      } catch (e) {
        return {
          "success": false,
          "message": "Server returned invalid JSON.",
          "rawResponse": responseBody,
        };
      }

      // ------------------------------------------------------
      // JSON MUST BE OBJECT
      // ------------------------------------------------------

      if (decoded is! Map) {
        return {
          "success": false,
          "message": "Invalid response received from disease API.",
        };
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

      // ------------------------------------------------------
      // HTTP ERROR
      // ------------------------------------------------------

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        return {
          "success": false,
          "message": data["message"]?.toString() ?? "Disease analysis failed.",
          "statusCode": streamedResponse.statusCode,
        };
      }

      // ------------------------------------------------------
      // BACKEND SUCCESS / FAILURE
      // ------------------------------------------------------

      if (data["success"] == false) {
        return data;
      }

      // ------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------

      if (data["success"] == true) {
        return data;
      }

      // ------------------------------------------------------
      // UNKNOWN RESPONSE
      // ------------------------------------------------------

      return {
        "success": false,
        "message": "Unexpected response from disease AI.",
        "data": data,
      };
    }
    // ========================================================
    // NETWORK ERROR
    // ========================================================
    on SocketException {
      return {
        "success": false,
        "message":
            "Cannot connect to Agrii AI server. "
            "Make sure the backend is running and "
            "your phone is connected to the same network.",
      };
    }
    // ========================================================
    // TIMEOUT
    // ========================================================
    on http.ClientException catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
    // ========================================================
    // TIMEOUT / OTHER ERROR
    // ========================================================
    catch (e) {
      return {"success": false, "message": "Disease analysis failed: $e"};
    }
  }

  // ==========================================================
  // CHECK API CONNECTION
  // ==========================================================
  //
  // Useful for testing:
  //
  // GET /api/disease
  //
  // ==========================================================

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final Uri url = Uri.parse(ApiConstants.diseaseUrl);

      final response = await http
          .get(url, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 10));

      if (response.body.trim().isEmpty) {
        return {
          "success": false,
          "message": "Disease API returned an empty response.",
        };
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {"success": false, "message": "Invalid disease API response."};
    } on SocketException {
      return {"success": false, "message": "Cannot connect to disease API."};
    } catch (e) {
      return {
        "success": false,
        "message": "Disease API health check failed: $e",
      };
    }
  }
}
