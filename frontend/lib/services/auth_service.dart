import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  // Increased timeout to 30 seconds for slower networks
  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // ==========================================================
  // REGISTER
  // ==========================================================

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String recoveryHint,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/register"),
            headers: _headers,
            body: jsonEncode({
              "name": name.trim(),
              "email": email.trim().toLowerCase(),
              "phone": phone.trim(),
              "password": password,
              "recoveryHint": recoveryHint.trim(),
              "role": "user",
            }),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response.body);
      if (data == null) return AuthResult.failure("Invalid server response");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.success(message: data["message"] ?? "Registration successful");
      }
      return AuthResult.failure(data["message"] ?? "Registration failed");
    } on TimeoutException {
      return AuthResult.failure("Server timeout. Check your Wi-Fi connection and IP address.");
    } on SocketException {
      return AuthResult.failure("Connection refused. Ensure the backend is running at ${ApiConstants.serverIp}");
    } catch (e) {
      return AuthResult.failure("Network error: $e");
    }
  }

  // ==========================================================
  // FARMER REGISTER
  // ==========================================================

  static Future<AuthResult> farmerRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String farmName,
    required String farmLocation,
    required String recoveryHint,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/register"),
            headers: _headers,
            body: jsonEncode({
              "name": name.trim(),
              "email": email.trim().toLowerCase(),
              "phone": phone.trim(),
              "password": password,
              "role": "farmer",
              "farmName": farmName.trim(),
              "farmLocation": farmLocation.trim(),
              "recoveryHint": recoveryHint.trim(),
            }),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response.body);
      if (data == null) return AuthResult.failure("Invalid server response");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.success(message: data["message"] ?? "Farmer registered!");
      }
      return AuthResult.failure(data["message"] ?? "Farmer registration failed");
    } on TimeoutException {
      return AuthResult.failure("Server timeout. Verify backend IP and Wi-Fi.");
    } on SocketException {
      return AuthResult.failure("Backend not reachable. Check server at ${ApiConstants.serverIp}");
    } catch (e) {
      return AuthResult.failure("Network error: $e");
    }
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  static Future<AuthResult> loginAnyRole({
    required String email,
    required String password,
  }) async {
    return _login(email: email, password: password);
  }

  static Future<AuthResult> _login({
    required String email,
    required String password,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();

    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/login"),
            headers: _headers,
            body: jsonEncode({"email": cleanEmail, "password": password}),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response.body);
      if (data == null) return AuthResult.failure("Invalid server response");

      if (response.statusCode == 200 && data["success"] == true) {
        final Map<String, dynamic> user = Map<String, dynamic>.from(data["user"]);
        final String token = data["token"] ?? "";
        final String userId = user["_id"] ?? user["id"] ?? "";
        final String role = user["role"] ?? "";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("userId", userId);
        await prefs.setString("name", user["name"] ?? "");
        await prefs.setString("email", user["email"] ?? "");
        await prefs.setString("role", role.toLowerCase());

        if (user["farmName"] != null) await prefs.setString("farmName", user["farmName"]);
        if (user["farmLocation"] != null) await prefs.setString("farmLocation", user["farmLocation"]);

        return AuthResult.success(message: "Welcome back!");
      }
      return AuthResult.failure(data["message"] ?? "Invalid email or password");
    } on TimeoutException {
      return AuthResult.failure("Login timeout. Ensure your phone can access the server.");
    } on SocketException {
      return AuthResult.failure("Cannot connect to server. Check IP: ${ApiConstants.serverIp}");
    } catch (e) {
      return AuthResult.failure("Error: $e");
    }
  }

  // ==========================================================
  // RESET PASSWORD
  // ==========================================================

  static Future<AuthResult> resetPassword({
    required String email,
    required String recoveryHint,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/reset-password"),
            headers: _headers,
            body: jsonEncode({
              "email": email.trim().toLowerCase(),
              "recoveryHint": recoveryHint.trim(),
              "newPassword": newPassword,
            }),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response.body);
      if (data == null) return AuthResult.failure("Invalid server response");

      if (response.statusCode == 200 && data["success"] == true) {
        return AuthResult.success(message: "Password updated successfully!");
      }
      return AuthResult.failure(data["message"] ?? "Reset failed");
    } on TimeoutException {
      return AuthResult.failure("Reset timeout. Check connection.");
    } on SocketException {
      return AuthResult.failure("Server unreachable.");
    } catch (e) {
      return AuthResult.failure("Error: $e");
    }
  }

  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
    await prefs.remove("role");
    await prefs.remove("email");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Map<String, dynamic>? _decodeResponse(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      return null;
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const AuthResult({required this.success, required this.message, this.data});

  factory AuthResult.success({String message = "Success", Map<String, dynamic>? data}) {
    return AuthResult(success: true, message: message, data: data);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}
