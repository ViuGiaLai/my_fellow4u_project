import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// CUSTOM EXCEPTIONS - Exception classes for API error handling

/// API Exception - thrown when API returns error or request fails
// Usage: catch (e) { if (e is ApiException) ... }
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  ApiException(this.message, {this.statusCode, this.endpoint});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Network Exception - thrown when there's no internet connection
// Usage: catch (e) { if (e is NetworkException) ... }
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Timeout Exception - thrown when request takes too long
// Usage: catch (e) { if (e is TimeoutException) ... }
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

// API SERVICE - Main API class for all HTTP requests

/// API Service class with timeout, retry, and error handling
// Usage: ApiService.getTours(), ApiService.getUserProfile(), etc.
class ApiService {
  // Timeout duration for all API requests
  static const Duration _timeout = Duration(seconds: 30);
  // Maximum retry attempts for failed requests
  static const int _maxRetries = 3;

  // BASE URL - Get current API base URL from environment
  // Usage: ApiService.baseUrl
  static String get baseUrl {
    final useLocal = dotenv.env['USE_LOCAL'] == 'true';
    var url = useLocal ? dotenv.env['API_URL_LOCAL']! : dotenv.env['API_URL_PROD']!;
    
    // Flutter Web: replace localhost with 127.0.0.1 to avoid CORS issues
    if (kIsWeb && url.contains('localhost')) {
      url = url.replaceAll('localhost', '127.0.0.1');
    }
    
    debugPrint("🌐 Base URL: $url");
    return url;
  }

  // CHECK INTERNET - Verify internet connection

  // Usage: if (await ApiService.hasInternet()) { ... }
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // GET HEADERS - Get HTTP headers with auth token

  // Usage: final headers = await ApiService.getHeaders();
  static Future<Map<String, String>> getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // TOKEN - Get stored authentication token (private)
  // Usage: Internal - called by getHeaders()
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final backendToken = prefs.getString('backend_token');
    debugPrint("🔑 Token: ${backendToken != null && backendToken.isNotEmpty ? 'CÓ' : 'KHÔNG'}");
    return backendToken;
  }

  // HTTP CLIENT WITH TIMEOUT
  static http.Client get _client => http.Client();

  // HELPER: _getList - GET request returning List

  // Usage: Internal - called by public API methods
  static Future<List<dynamic>> _getList(
    String endpoint, {
    int retries = _maxRetries,
    bool requireAuth = false,
  }) async {
    // Retry loop
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final headers = requireAuth ? await getHeaders() : null;
        final response = await _client
            .get(
              Uri.parse('$baseUrl$endpoint'),
              headers: headers,
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['data'] ?? [];
        } else {
          debugPrint("❌ $endpoint: ${response.statusCode}");
        }
      } on SocketException catch (e) {
        debugPrint("❌ SocketException: $e");
        if (attempt == retries - 1) {
          throw NetworkException('Lỗi kết nối mạng');
        }
      } on TimeoutException catch (e) {
        debugPrint("❌ Timeout: $e");
        if (attempt == retries - 1) {
          throw TimeoutException('Yêu cầu bị quá thời gian. Thử lại sau!');
        }
      } catch (_) {
        if (attempt == retries - 1) {
          throw ApiException('Lỗi không xác định', endpoint: endpoint);
        }
      }
      // Wait before retry
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    return [];
  }

  static Future<Map<String, dynamic>?> _getAuthenticatedItem(
    String endpoint, {
    int retries = _maxRetries,
  }) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final headers = await getHeaders();
        debugPrint("📤 Headers: $headers");
        final response = await _client
            .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
            .timeout(_timeout);

        debugPrint("📥 $endpoint: ${response.statusCode}");
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['data'];
        } else {
          debugPrint("❌ $endpoint: ${response.statusCode}");
        }
      } on SocketException {
        if (attempt == retries - 1) {
          throw NetworkException('Lỗi kết nối mạng');
        }
      } on TimeoutException {
        if (attempt == retries - 1) {
          throw TimeoutException('Quá thời gian chờ!');
        }
      } catch (_) {
        if (attempt == retries - 1) {
          throw ApiException('Lỗi không xác định', endpoint: endpoint);
        }
      }
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    return null;
  }

  static Future<Map<String, dynamic>?> _putAuthenticated(
    String endpoint,
    Map<String, dynamic> data, {
    int retries = _maxRetries,
  }) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final headers = await getHeaders();
        final response = await _client
            .put(
              Uri.parse('$baseUrl$endpoint'),
              headers: headers,
              body: json.encode(data),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          return result['data'];
        } else {
          debugPrint("❌ PUT $endpoint: ${response.statusCode}");
        }
      } catch (_) {
        if (attempt == retries - 1) {
          throw ApiException('Lỗi cập nhật', endpoint: endpoint);
        }
      }
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    return null;
  }

  static Future<bool> _deleteAuthenticated(
    String endpoint, {
    int retries = _maxRetries,
  }) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final headers = await getHeaders();
        final response = await _client
            .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
            .timeout(_timeout);
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (_) {
        if (attempt == retries - 1) {
          debugPrint("❌ Delete error");
        }
      }
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    return false;
  }

  // PUBLIC APIs - GET public data (no auth required)

  // Usage: final tours = await ApiService.getTours();
  static Future<List<dynamic>> getTours() => _getList('/tours');
  static Future<List<dynamic>> getFellows() => _getList('/fellows');
  static Future<List<dynamic>> getPlaces() => _getList('/places');
  static Future<List<dynamic>> getBlogs() => _getList('/blogs');
  static Future<List<dynamic>> getExperiences() => _getList('/experiences');

  // 
  // TRIPS API - Trip CRUD operations (auth required)
  // 
  // Usage: final trips = await ApiService.getTrips();
  static Future<List<dynamic>> getTrips() async {
    return _getList('/trips', requireAuth: true);
  }

  // Usage: final trip = await ApiService.getTrip('trip_id');
  static Future<Map<String, dynamic>?> getTrip(String id) {
    return _getAuthenticatedItem('/trips/$id');
  }

  // CREATE TRIP - Create new trip (auth required)

  // Usage: final trip = await ApiService.createTrip(title: '...', destination: '...', ...);
  static Future<Map<String, dynamic>?> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    int travelerCount = 1,
    double? maxBudget,
    List<String>? requiredLanguages,
    String? imageUrl,
  }) async {
    try {
      final headers = await getHeaders();
      final body = json.encode({
        'title': title,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'travelerCount': travelerCount,
        'maxBudget': maxBudget,
        'requiredLanguages': requiredLanguages ?? [],
        'imageUrl': imageUrl,
      });

      final response = await _client
          .post(Uri.parse('$baseUrl/trips'), headers: headers, body: body)
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      throw ApiException('Tạo trip thất bại', statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw ApiException('Lỗi tạo trip');
    }
  }

  // UPDATE TRIP - Update existing trip (auth required)

  // Usage: final trip = await ApiService.updateTrip('trip_id', {...});
  static Future<Map<String, dynamic>?> updateTrip(
    String id,
    Map<String, dynamic> data,
  ) {
    return _putAuthenticated('/trips/$id', data);
  }

  // Usage: await ApiService.deleteTrip('trip_id');
  static Future<bool> deleteTrip(String id) {
    return _deleteAuthenticated('/trips/$id');
  }

  // USER PROFILE - User profile operations (auth required)

  // Usage: final profile = await ApiService.getUserProfile();
  static Future<Map<String, dynamic>?> getUserProfile() {
    return _getAuthenticatedItem('/users/profile');
  }

  // Usage: await ApiService.updateUserProfile({...});
  static Future<Map<String, dynamic>?> updateUserProfile(
    Map<String, dynamic> data,
  ) {
    return _putAuthenticated('/users/profile', data);
  }

  // Usage: final user = await ApiService.getMe();
  static Future<Map<String, dynamic>?> getMe() {
    return _getAuthenticatedItem('/auth/me');
  }

  // PHOTOS - Supabase storage photo operations (auth required)

  // Usage: final photos = await ApiService.getUserPhotos();
  static Future<List<dynamic>> getUserPhotos() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw ApiException('User chưa đăng nhập');
      }

      final response = await Supabase.instance.client.storage
          .from('user_photos')
          .list(path: 'photos/${user.id}')
          .timeout(_timeout);

      if (response.isEmpty) {
        return [];
      }

      final photos = <dynamic>[];
      for (final file in response) {
        final url = Supabase.instance.client.storage
            .from('user_photos')
            .getPublicUrl('photos/${user.id}/${file.name}');
        photos.add({
          'id': file.name,
          'url': url,
          'fileName': file.name,
        });
      }
      return photos;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Lỗi lấy photos');
    }
  }

  // UPLOAD PHOTO - Upload photo to Supabase (auth required)

  // Usage: final photo = await ApiService.uploadPhoto(bytes, 'filename.jpg', 'desc');
  static Future<Map<String, dynamic>?> uploadPhoto(
    Uint8List fileBytes,
    String fileName,
    String? description,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw ApiException('User chưa đăng nhập');
      }
      final userId = user.id;
      final path = 'photos/$userId/$fileName';

      await supabase.storage
          .from('user_photos')
          .uploadBinary(path, fileBytes)
          .timeout(_timeout);

      final publicUrl = supabase.storage.from('user_photos').getPublicUrl(path);

      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'url': publicUrl,
        'description': description,
        'fileName': fileName,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Lỗi upload photo');
    }
  }

  // DELETE PHOTO - Delete photo from Supabase (auth required)

  // Usage: await ApiService.deletePhoto('photo_url');
  static Future<bool> deletePhoto(String photoUrl) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw ApiException('User chưa đăng nhập');
      }

      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return false;

      var fileName = pathSegments.last;
      if (fileName.contains('?')) {
        fileName = fileName.split('?').first;
      }

      await Supabase.instance.client.storage
          .from('user_photos')
          .remove(['photos/${user.id}/$fileName'])
          .timeout(_timeout);

      return true;
    } catch (_) {
      debugPrint("❌ Delete photo error");
      return false;
    }
  }

  // CHAT APIs - Chat/messaging operations (auth required)

  // Usage: final conversations = await ApiService.getConversations();
  static Future<List<dynamic>> getConversations() async {
    return _getList('/chat/conversations', requireAuth: true);
  }

  // Usage: final messages = await ApiService.getMessages('conversation_id');
  static Future<List<dynamic>> getMessages(String conversationId) async {
    return _getList(
      '/chat/conversations/$conversationId/messages',
      requireAuth: true,
    );
  }

  // SEND MESSAGE - Send chat message (auth required)

  // Usage: final message = await ApiService.sendMessage('conversation_id', 'Hello!');
  static Future<Map<String, dynamic>?> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await _client
          .post(
            Uri.parse('$baseUrl/chat/messages'),
            headers: headers,
            body: json.encode({
              'conversationId': conversationId,
              'content': content,
              'type': 'text',
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      throw ApiException('Gửi tin nhắn thất bại', statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw ApiException('Lỗi gửi tin nhắn');
    }
  }

  // CREATE CONVERSATION - Create new chat (auth required)

  // Usage: final conv = await ApiService.createConversation('user_id');
  static Future<Map<String, dynamic>?> createConversation(
    String participantId,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await _client
          .post(
            Uri.parse('$baseUrl/chat/conversations'),
            headers: headers,
            body: json.encode({'participantId': participantId}),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      throw ApiException('Tạo cuộc trò chuyện thất bại',
          statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw ApiException('Lỗi tạo cuộc trò chuyện');
    }
  }

  // 
  // SEARCH CHAT USERS - Search users for chat (auth required)
  // 
  // Usage: final users = await ApiService.searchChatUsers('john');
  static Future<List<dynamic>> searchChatUsers(String query) async {
    return _getList(
      '/chat/users?q=${Uri.encodeComponent(query)}',
      requireAuth: true,
    );
  }

  // 
  // UPLOAD TRIP IMAGE - Upload trip image to Supabase (auth required)
  // 
  // Usage: final url = await ApiService.uploadTripImage(bytes, 'trip.jpg');
  static Future<String?> uploadTripImage(Uint8List fileBytes, String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw ApiException('User chưa đăng nhập');
      }
      final userId = user.id;
      final path = 'trips/$userId/$fileName';

      await supabase.storage
          .from('trip_images')
          .uploadBinary(path, fileBytes)
          .timeout(_timeout);

      return supabase.storage.from('trip_images').getPublicUrl(path);
    } catch (_) {
      debugPrint("❌ Upload image error");
      return null;
    }
  }
}

// ====
// END OF API SERVICE
// ====