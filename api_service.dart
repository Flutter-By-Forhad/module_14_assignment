import 'dart:convert';
import 'package:http/http.dart' as http;

// API Service class to handle all API calls
class ApiService {
  static const String baseUrl = 'https://reqres.in/api';

  // Register a new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 && !responseBody.containsKey('error')) {
      return responseBody;
    } else {
      final errorMessage = responseBody['error'] ?? 'Failed to register';
      throw Exception(errorMessage);
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 && !responseBody.containsKey('error')) {
      return responseBody;
    } else {
      final errorMessage = responseBody['error'] ?? 'Failed to login';
      throw Exception(errorMessage);
    }
  }

  // Get user profile (Read)
  Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      // FIX: The API response for a single user is { "data": { ... } }.
      // The jsonDecode() parses this, and we need to extract the inner map.
      return jsonDecode(response.body)['data'];
    }
    else if (response.statusCode == 404) {
      throw Exception('User with ID $userId not found.');
    }
    else {
      // For all other errors, throw a generic failure message.
      throw Exception('Failed to get profile: Status code ${response.statusCode}');
    }
  }

  // Update user profile (Update)
  Future<Map<String, dynamic>> updateProfile(int userId, String name, String job) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'job': job}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // Delete user account (Delete)
  Future<void> deleteAccount(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    // A 204 No Content response is the expected successful response for a DELETE request
    if (response.statusCode != 204) {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }
}
