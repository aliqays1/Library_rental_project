import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Future<bool> registerUser(String username, String email, String password) async {
    try {
      // FIX: Ensure this path is /api/auth/register
      final url = Uri.parse('$baseUrl/api/auth/register');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registration Success");
        return true;
      } else {
        // This will now print the JSON error message from our new controller
        print("Registration Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Connection Error: $e");
      return false;
    }
  }
}