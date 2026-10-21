import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  // ==========================================================
  // AGRII AI BACKEND
  // ==========================================================

  static const String _baseUrl = "http://10.253.175.78:5000";

  static const String _chatbotUrl = "$_baseUrl/api/chatbot/message";

  // ==========================================================
  // SEND MESSAGE
  // ==========================================================

  Future<String> sendMessage(String message) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return "Please ask an Agrii related question.";
    }

    try {
      debugPrint("🌾 Sending message to Agrii AI...");

      final response = await http
          .post(
            Uri.parse(_chatbotUrl),
            headers: const {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"message": cleanMessage}),
          )
          .timeout(const Duration(seconds: 50));

      debugPrint("🌾 Status: ${response.statusCode}");

      debugPrint("🌾 Body: ${response.body}");

      Map<String, dynamic>? data;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        debugPrint("❌ JSON error: $e");
      }

      // ======================================================
      // SUCCESS
      // ======================================================

      if (response.statusCode == 200) {
        final reply = data?["reply"];

        if (reply != null && reply.toString().trim().isNotEmpty) {
          return reply.toString().trim();
        }

        return "Agrii AI could not generate a response. Please try again.";
      }

      // ======================================================
      // RATE LIMIT / QUOTA
      // ======================================================

      if (response.statusCode == 429) {
        return "Agrii AI request limit has been reached. Please try again later.";
      }

      // ======================================================
      // TIMEOUT
      // ======================================================

      if (response.statusCode == 504) {
        return "Agrii AI took too long to respond. Please try again.";
      }

      // ======================================================
      // SERVICE UNAVAILABLE
      // ======================================================

      if (response.statusCode == 503) {
        return "Agrii AI is temporarily busy. Please try again.";
      }

      // ======================================================
      // MODEL ERROR
      // ======================================================

      if (response.statusCode == 502) {
        return "Agrii AI service is temporarily unavailable. Please try again later.";
      }

      // ======================================================
      // BAD REQUEST
      // ======================================================

      if (response.statusCode == 400) {
        final message = data?["message"];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }

        return "Please ask an Agrii related question.";
      }

      // ======================================================
      // SERVER ERROR
      // ======================================================

      return "Agrii AI is temporarily unavailable. Please try again later.";
    } on TimeoutException {
      debugPrint("❌ Agrii AI timeout");

      return "Agrii AI took too long to respond. Please try again.";
    } on http.ClientException catch (e) {
      debugPrint("❌ HTTP error: $e");

      return "Unable to connect to Agrii AI server. Please check your network connection.";
    } catch (e) {
      debugPrint("❌ Agrii AI error: $e");

      return "Agrii AI is temporarily unavailable. Please try again later.";
    }
  }
}
