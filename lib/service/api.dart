import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://192.168.2.2:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token retrieved: $token"); // Debugging line
    return token;
  }

  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print("Token saved: $token"); // Debugging line
  }

  Future<http.Response> _request(String method, String endpoint,
      {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = method == 'POST'
          ? await http.post(url, headers: headers, body: jsonEncode(data))
          : await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed request: $e');
    }
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('Error in GET request: $e');
      throw Exception('Failed to make GET request');
    }
  }

// Login
  Future<http.Response> login(String email, String password) async {
    print("Attempting login with email: $email");

    final response = await _request('POST', 'login', data: {
      'email': email,
      'password': password,
    });

    print("Received response with status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Login response data: $responseData");

      // Check for access_token in the response
      if (responseData.containsKey('access_token') &&
          responseData['access_token'] != null) {
        final token = responseData['access_token'];
        print("Access token found: $token");

        // Attempt to store the token
        try {
          await storeToken(token);
          print("Token stored successfully.");
        } catch (e) {
          print("Error storing token: $e");
          throw Exception('Failed to store token');
        }
      } else {
        print("Access token not found in response.");
        throw Exception('Login failed: Access token missing in response');
      }
    } else {
      print("Login failed with response: ${response.body}");
      throw Exception('Failed to login: ${response.body}');
    }

    return response;
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse(response);
    } catch (e) {
      print('Error in POST request: $e');
      throw Exception('Failed to make POST request');
    }
  }

  // Fetch labs from backend
  Future<http.Response> getLabs() async {
    return await get('labs');
  }

  // Fetch study times from backend
  Future<http.Response> getSessions() async {
    return await get('study-times');
  }

  // Helper function to handle response status codes
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response; // Success
    } else {
      throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<http.Response> getUserProfile() async {
    return await _request('GET', 'user/profile');
  }

  // Method to delete a resource by ID
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);

      // Check for successful delete
      if (response.statusCode == 204) {
        print('Delete successful');
      } else {
        print('Delete failed: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error deleting resource: $e');
      throw Exception('Failed to delete resource');
    }
  }
}
