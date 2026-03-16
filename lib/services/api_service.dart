import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://backend-mobile-api-a4n4.onrender.com/api/v1'; // Thay đổi thành IP server của bạn

  static Future<List<dynamic>> getTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tours'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching tours: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getFellows() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/fellows'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching fellows: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getPlaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getBlogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blogs'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching blogs: $e');
    }
    return [];
  }
  static Future<List<dynamic>> getExperiences() async {
    final response = await http.get(Uri.parse('$baseUrl/experiences' ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    return [];
  }
}
