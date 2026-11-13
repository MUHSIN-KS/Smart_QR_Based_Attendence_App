import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token Management
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(AppConstants.keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyToken);
  }

  Future<bool> removeToken() async {
    return await _prefs.remove(AppConstants.keyToken);
  }

  // User Profile
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    return await _prefs.setString(AppConstants.keyUser, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(AppConstants.keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeUser() async {
    return await _prefs.remove(AppConstants.keyUser);
  }

  // Custom Base URL
  Future<bool> saveBaseUrl(String url) async {
    return await _prefs.setString(AppConstants.keyBaseUrl, url);
  }

  String? getBaseUrl() {
    return _prefs.getString(AppConstants.keyBaseUrl);
  }

  // Clear all session data on logout
  Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}

