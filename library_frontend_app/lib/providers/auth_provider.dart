import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  String get baseUrl {
    if (kIsWeb) return "http://localhost:5000/api"; 
    return "http://10.0.2.2:5000/api";
  }

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedData['token'];
    _user = {
      "id": extractedData['id'],
      "username": extractedData['username'],
      "email": extractedData['email'],
      "role": extractedData['role'],
    };
    notifyListeners();
    return true;
  }

  Future<void> register(String username, String email, String mobile, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username.trim(),
          "email": email.trim().toLowerCase(),
          "mobile": mobile,
          "password": password,
          "role": "user"
        }),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? "Registration failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username.trim(), "password": password}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        _token = data['token'];
        _user = {
          "id": data['_id'], 
          "username": data['username'],
          "email": data['email'] ?? "", 
          "role": data['role'] ?? "user"
        };
        final prefs = await SharedPreferences.getInstance();
        await _saveToStorage(prefs);
        notifyListeners();
      } else {
        throw Exception(data['message'] ?? "Login failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- UPDATED SECURE DELETE LOGIC ---
  Future<bool> deleteUserAccount() async {
    if (_token == null || _user == null) return false;
    try {
      // Points to /api/users/delete (defined in userRoutes.js)
      // No ID needed in the URL because the protect middleware finds the user via Token
      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete'), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token", 
        },
      ).timeout(const Duration(seconds: 10));

      // Check for 200 (Success)
      if (response.statusCode == 200) {
        logout();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 Delete Error: $e");
      return false;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-email'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: json.encode({"email": newEmail.trim().toLowerCase()}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        _user!['email'] = newEmail.trim().toLowerCase();
        final prefs = await SharedPreferences.getInstance();
        await _saveToStorage(prefs);
        notifyListeners();
      } else {
        throw Exception(data['message'] ?? "Failed to update email");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-password'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: json.encode({"oldPassword": oldPassword, "newPassword": newPassword}),
      );
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? "Failed to update password");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveToStorage(SharedPreferences prefs) async {
    final userData = json.encode({
      'token': _token,
      'id': _user!['id'],
      'username': _user!['username'],
      'email': _user!['email'],
      'role': _user!['role'],
    });
    await prefs.setString('userData', userData);
  }

  void logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}