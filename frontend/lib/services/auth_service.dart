import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  // 60-second timeout to handle Render cold-starts and slower networks
  static const Duration _timeout = Duration(seconds: 60);

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

      return _processResponse(
        response,
        defaultSuccess: "Registration successful",
        defaultFailure: "Registration failed",
      );
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

      return _processResponse(
        response,
        defaultSuccess: "Farmer registered!",
        defaultFailure: "Farmer registration failed",
      );
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
      if (data == null) {
        if (response.statusCode == 404) {
          return AuthResult.failure("Login endpoint not found (404). Check backend server URL.");
        }
        return AuthResult.failure("Server error (${response.statusCode}). Check backend.");
      }

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

        if (role.toLowerCase() == "admin") {
          await prefs.setString("adminToken", token);
          await prefs.setString("adminId", userId);
          await prefs.setString("adminName", user["name"] ?? "");
          await prefs.setString("adminEmail", user["email"] ?? "");
        }

        return AuthResult.success(message: "Welcome back!", data: data);
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
  // ADMIN LOGIN
  // ==========================================================

  static Future<AuthResult> loginAdmin({
    required String email,
    required String password,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();

    try {
      // 1. Try dedicated admin endpoint
      final response = await http
          .post(
            Uri.parse("${ApiConstants.adminUrl}/login"),
            headers: _headers,
            body: jsonEncode({"email": cleanEmail, "password": password}),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response.body);

      if (response.statusCode == 200 && data != null && data["success"] == true) {
        final String token = data["token"] ?? "";
        final Map<String, dynamic> adminData =
            Map<String, dynamic>.from(data["admin"] ?? {});
        final String adminId = adminData["_id"] ?? adminData["id"] ?? "";
        final String adminName = adminData["name"] ?? "Admin";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("adminToken", token);
        await prefs.setString("adminId", adminId);
        await prefs.setString("adminName", adminName);
        await prefs.setString("adminEmail", cleanEmail);
        await prefs.setString("token", token);
        await prefs.setString("userId", adminId);
        await prefs.setString("name", adminName);
        await prefs.setString("email", cleanEmail);
        await prefs.setString("role", "admin");

        return AuthResult.success(
          message: "Admin authentication successful!",
          data: data,
        );
      }

      // 2. Fallback to general login endpoint
      final fallbackResult = await _login(email: cleanEmail, password: password);
      if (fallbackResult.success) {
        final currentRole = await getRole();
        if (currentRole == "admin") {
          return fallbackResult;
        }
      }

      return AuthResult.failure(data?["message"] ?? "Invalid admin credentials");
    } on TimeoutException {
      return AuthResult.failure("Admin login timed out. Check server connectivity.");
    } on SocketException {
      return AuthResult.failure("Server unreachable at ${ApiConstants.serverIp}");
    } catch (e) {
      return AuthResult.failure("Admin login error: $e");
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

      return _processResponse(
        response,
        defaultSuccess: "Password updated successfully!",
        defaultFailure: "Reset failed",
      );
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
    await prefs.remove("name");
    await prefs.remove("adminToken");
    await prefs.remove("adminId");
    await prefs.remove("adminName");
    await prefs.remove("adminEmail");
    await prefs.remove("farmName");
    await prefs.remove("farmLocation");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("adminToken") ?? prefs.getString("token");
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }

  static Map<String, dynamic>? _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static AuthResult _processResponse(
    http.Response response, {
    required String defaultSuccess,
    required String defaultFailure,
  }) {
    final data = _decodeResponse(response.body);

    if (data == null) {
      if (response.statusCode == 404) {
        return AuthResult.failure(
          "Endpoint not found (404). Check backend server URL.",
        );
      }
      if (response.statusCode == 409) {
        return AuthResult.failure(
          "An account with these details already exists. Please login.",
        );
      }
      if (response.statusCode >= 500) {
        return AuthResult.failure(
          "Server error (${response.statusCode}). Please ensure backend is running.",
        );
      }
      return AuthResult.failure(
        "Server returned status ${response.statusCode}.",
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResult.success(
        message: data["message"] ?? defaultSuccess,
        data: data,
      );
    }

    return AuthResult.failure(data["message"] ?? defaultFailure);
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
