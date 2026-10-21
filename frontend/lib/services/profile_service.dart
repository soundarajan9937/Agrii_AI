import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class ProfileService {
  static const String key = "user_profile";

  // Save Profile
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(user.toJson()));
  }

  // Get Profile
  static Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) {
      return UserModel(
        name: "Farmer",
        email: "farmer@gmail.com",
        phone: "",
        address: "",
        farmName: "",
        farmLocation: "",
        farmSize: "",
        mainCrop: "",
        soilType: "",
        profileImage: "",
      );
    }

    return UserModel.fromJson(jsonDecode(data));
  }
}
