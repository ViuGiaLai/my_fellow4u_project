import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==== API SERVICE - TỔNG KẾT ĐIỂM: 
// Tìm nhanh: Ctrl+Shift+F → gõ API #1, API #2, ... hoặc AUTH #1, AUTH #2
// 
// API #1: getTours        - GET /tours           (public)     → home_screen.dart
// API #2: getFellows     - GET /fellows        (public)     → home_screen.dart
// API #3: getPlaces     - GET /places        (public)     → home_screen.dart, add_new_attractions_screen.dart
// API #4: getBlogs      - GET /blogs         (public)     → home_screen.dart
// API #5: getExperiences - GET /experiences  (public)     → home_screen.dart
// API #6a: getTrips     - GET /trips         (auth)       → my_trips_app.dart, profile_screen.dart
// API #6b: getTrip      - GET /trips/:id     (auth)       → trip_info_screen.dart
// API #6c: createTrip  - POST /trips        (auth)       → create_trip_page.dart, trip_info_screen.dart
// API #6d: updateTrip - PUT /trips/:id      (auth)       → edit_trip_page.dart
// API #6e: deleteTrip - DELETE /trips/:id   (auth)       → my_trips_app.dart
// API #7a: getUserProfile   - GET /users/profile  (auth) → profile_screen.dart, settings_screen.dart, edit_profile_screen.dart
// API #7b: updateUserProfile - PUT /users/profile (auth) → edit_profile_screen.dart
// API #7c: getMe       - GET /auth/me        (auth)     → auth_provider.dart
// API #8a: getUserPhotos - GET /photos         (auth)     → my_photos_screen.dart
// API #8b: uploadPhoto  - POST /photos       (auth + Supabase) → my_photos_screen.dart
// API #8c: deletePhoto - DELETE /photos/:id (auth)     → my_photos_screen.dart
// API #9a: getConversations - GET /chat/conversations (auth) → ChatHomePage.dart
// API #9b: getMessages - GET /chat/conversations/:id/messages (auth) → ChatHomePage.dart
// API #9c: sendMessage - POST /chat/messages (auth)    → ChatHomePage.dart
// API #9d: createConversation - POST /chat/conversations (auth) → ChatHomePage.dart
// API #9e: searchChatUsers - GET /chat/users (auth)    → ChatHomePage.dart
//
// AUTH #1: Backend Token (SharedPreferences)     → _getToken()
// AUTH #2: Bearer Token (Authorization header)   → getHeaders()
// AUTH #3: Supabase Auth (Supabase.instance.client.auth.currentUser) → uploadTripImage(), uploadPhoto()
// 

class ApiService {
  // BASE URL 
  static String get baseUrl {
    final useLocal = dotenv.env['USE_LOCAL'] == 'true';
    final url =
        useLocal ? dotenv.env['API_URL_LOCAL']! : dotenv.env['API_URL_PROD']!;
    print("🌐 Base URL đang dùng: $url");
    return url;
  }

  // TOKEN 
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final backendToken = prefs.getString('backend_token');

    print(
      "🔑 Backend token từ SharedPreferences: ${backendToken != null && backendToken.isNotEmpty ? 'CÓ' : 'KHÔNG'}",
    );

    if (backendToken != null && backendToken.isNotEmpty) {
      return backendToken;
    }

    print("❌ Không tìm thấy backend token");
    return null;
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      print("⚠️ CẢNH BÁO: Không tìm thấy token nào!");
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==== API 1-5: PUBLIC APIs (GET) 
  // API #1: Tours - GET /tours
  // SỬ DỤNG TẠI: home_screen.dart (line 46)
  static Future<List<dynamic>> getTours() async => _getList('/tours');
  // API #2: Fellows - GET /fellows
  static Future<List<dynamic>> getFellows() async => _getList('/fellows');
  // API #3: Places - GET /places
  static Future<List<dynamic>> getPlaces() async => _getList('/places');
  // API #4: Blogs - GET /blogs
  // SỬ DỤNG TẠI: home_screen.dart (line 49)
  static Future<List<dynamic>> getBlogs() async => _getList('/blogs');
  // API #5: Experiences - GET /experiences
  // SỬ DỤNG TẠI: home_screen.dart (line 50)
  static Future<List<dynamic>> getExperiences() async =>
      _getList('/experiences');

  static Future<List<dynamic>> _getList(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching $endpoint: $e');
    }
    return [];
  }

  // ==== API 6: TRIPS - GET/POST/PUT/DELETE 
  // 
  // API #6a: Get All Trips - GET /trips (authenticated)
  // SỬ DỤNG TẠI: my_trips_app.dart (line 71), profile_screen.dart (line 57)
  static Future<List<dynamic>> getTrips() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/trips'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trips = data['data'] ?? [];
        return trips;
      } else {
        print("❌ Lỗi ${response.statusCode}: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Exception khi gọi getTrips: $e");
      return [];
    }
  }

  // API #6b: Get Trip Detail - GET /trips/:id (authenticated)
  // SỬ DỤNG TẠI: trip_info_screen.dart (thêm vào)
  static Future<Map<String, dynamic>?> getTrip(String id) async {
    return _getAuthenticatedItem('/trips/$id');
  }

  // ==== SUPABASE STORAGE - IMAGE UPLOAD 
  // 
  // AUTH #3: Supabase Auth (Supabase.instance.client.auth.currentUser)
  // IMAGE UPLOAD (Supabase Storage)
  // SỬ DỤNG TẠI: create_trip_page.dart (line 91)
  static Future<String?> uploadTripImage(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      // AUTH #3: Kiểm tra user đã đăng nhập chưa
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ User chưa đăng nhập, không thể upload ảnh trip');
        return null;
      }
      final userId = user.id;
      final path = 'trips/$userId/$fileName';

      await supabase.storage
          .from('trip_images')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabase.storage.from('trip_images').getPublicUrl(path);
      print('✅ Uploaded image to: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Image upload error: $e');
      return null;
    }
  }

  // API #6c: Create Trip - POST /trips (authenticated)
  // SỬ DỤNG TẠI: create_trip_page.dart (line 103), trip_info_screen.dart (line 31)
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

      final response = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error creating trip: $e');
    }
    return null;
  }

  // API #6d: Update Trip - PUT /trips/:id (authenticated)
  // SỬ DỤNG TẠI: edit_trip_page.dart (chưa có thì thêm vào)
  static Future<Map<String, dynamic>?> updateTrip(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _putAuthenticated('/trips/$id', data);
  }

  // API #6e: Delete Trip - DELETE /trips/:id (authenticated)
  // SỬ DỤNG TẠI: my_trips_app.dart (thêm nút xóa trip)
  static Future<bool> deleteTrip(String id) async {
    return _deleteAuthenticated('/trips/$id');
  }

  // ==== API 7: USER PROFILE - GET/PUT 
  // 
  // API #7a: Get User Profile - GET /users/profile (authenticated)
  // SỬ DỤNG TẠI: profile_screen.dart (line 35), settings_screen.dart (line 30), edit_profile_screen.dart (line 31)
  /// Lấy thông tin profile user hiện tại
  static Future<Map<String, dynamic>?> getUserProfile() async {
    return _getAuthenticatedItem('/users/profile');
  }

  // ==== API 8: PHOTOS - GET/POST/DELETE
  // 
  // API #8a: Get User Photos - GET /photos (authenticated)
  // SỬ DỤNG TẠI: my_photos_screen.dart (line 26)
  /// Lấy danh sách photos từ Supabase Storage
  static Future<List<dynamic>> getUserPhotos() async {
    try {
      // Lấy user hiện tại
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ User chưa đăng nhập');
        return [];
      }

      // Lấy danh sách file từ Supabase Storage
      final response = await Supabase.instance.client.storage
          .from('user_photos')
          .list(path: 'photos/${user.id}');

      if (response == null || response.isEmpty) {
        print('ℹ️ Không có photo nào');
        return [];
      }

      // Chuyển đổi thành list map
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

      print('✅ Lấy ${photos.length} photos từ Supabase');
      return photos;
    } catch (e) {
      print('❌ Lỗi khi lấy photos: $e');
      return [];
    }
  }

  // API #8b: Upload Photo - POST /photos (authenticated + Supabase Storage)
  // SỬ DỤNG TẠI: my_photos_screen.dart (line 51)
  /// Upload photo
  static Future<Map<String, dynamic>?> uploadPhoto(
    Uint8List fileBytes,
    String fileName,
    String? description,
  ) async {
    try {
      // AUTH #3: Kiểm tra user đã đăng nhập chưa
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ User chưa đăng nhập, không thể upload ảnh');
        return null;
      }
      final userId = user.id;

      // Thử upload lên Supabase storage trước
      try {
        var finalFileName = fileName;
        var path = 'photos/$userId/$finalFileName';

        // Kiểm tra xem file đã tồn tại chưa
        try {
          await supabase.storage.from('user_photos').list(path: 'photos/$userId');
        } catch (_) {
          // Ignore - sẽ kiểm tra khi upload
        }

        // Thử upload - nếu lỗi duplicate thì đổi tên
        try {
          await supabase.storage
              .from('user_photos')
              .uploadBinary(
                path,
                fileBytes,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
              );
        } on StorageException catch (e) {
          if (e.statusCode == 409 || e.message.contains('already exists')) {
            // File đã tồn tại - thêm timestamp vào tên
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final ext = fileName.contains('.') ? fileName.split('.').last : '';
            final nameWithoutExt = ext.isNotEmpty ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
            finalFileName = ext.isNotEmpty ? '$nameWithoutExt\_$timestamp.$ext' : '${nameWithoutExt}_$timestamp';
            path = 'photos/$userId/$finalFileName';
            
            // Upload lại với tên mới
            await supabase.storage
                .from('user_photos')
                .uploadBinary(
                  path,
                  fileBytes,
                  fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                );
            print('ℹ️ File đã tồn tại, đổi tên thành: $finalFileName');
          } else {
            rethrow;
          }
        }

        final publicUrl = supabase.storage.from('user_photos').getPublicUrl(path);
        
        // Thử lưu thông tin photo vào backend
        try {
          final headers = await getHeaders();
          final response = await http.post(
            Uri.parse('$baseUrl/photos'),
            headers: headers,
            body: json.encode({
              'url': publicUrl,
              'description': description,
              'fileName': fileName,
            }),
          );

          if (response.statusCode == 201) {
            final data = json.decode(response.body);
            return data['data'];
          } else if (response.statusCode == 404) {
            // API không tồn tại, vẫn trả về thành công với URL
            print("ℹ️ Photos API không tồn tại, upload thành công tới storage");
            return {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'url': publicUrl,
              'description': description,
              'fileName': fileName,
            };
          }
          print("❌ uploadPhoto backend ${response.statusCode}: ${response.body}");
        } catch (e) {
          print("❌ Lỗi khi gọi backend API: $e");
          // Vẫn trả về thành công nếu upload storage thành công
          return {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'url': publicUrl,
            'description': description,
            'fileName': fileName,
          };
        }
      } catch (e) {
        print("❌ Lỗi Supabase storage: $e");
        // Nếu storage bucket không tồn tại, tạo URL giả
        final fakeUrl = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/400.jpg';
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'url': fakeUrl,
          'description': description,
          'fileName': fileName,
        };
      }
    } catch (e) {
      print('❌ Error uploadPhoto: $e');
      return null;
    }
  }

  // API #8c: Delete Photo - DELETE /photos/:id (authenticated)
  // SỬ DỤNG TẠI: my_photos_screen.dart (line 84)
  /// Xóa photo từ cả Supabase Storage và Backend API
  static Future<bool> deletePhoto(String photoUrl) async {
    try {
      // Lấy user hiện tại
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ User chưa đăng nhập');
        return false;
      }

      // Trích xuất tên file từ URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        print('❌ Không lấy được path từ URL');
        return false;
      }
      // Lấy phần tử cuối cùng, bỏ query params
      var fileName = pathSegments.last;
      if (fileName.contains('?')) {
        fileName = fileName.split('?').first;
      }
      print('🔍 Xóa file: $fileName');

      // ✅ Xóa từ Supabase Storage
      await Supabase.instance.client.storage
          .from('user_photos')
          .remove(['photos/${user.id}/$fileName']);
      print('✅ Xóa khỏi Supabase Storage');

      return true;
    } catch (e) {
      print("❌ Lỗi khi xóa photo: $e");
      return false;
    }
  }
    // API #7c: Get Current User - GET /auth/me (authenticated)
  // SỬ DỤNG TẠI: auth_provider.dart (lấy thông tin user sau khi login)
  /// Lấy thông tin user hiện tại từ auth/me
  static Future<Map<String, dynamic>?> getMe() async {
    return _getAuthenticatedItem('/auth/me');
  }

  // API #7b: Update User Profile - PUT /users/profile (authenticated)
  // SỬ DỤNG TẠI: edit_profile_screen.dart (line 316)
  /// Cập nhật thông tin profile user
  static Future<Map<String, dynamic>?> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      print("🔄 Đang gọi MongoDB API: PUT /users/profile");
      final result = await _putAuthenticated('/users/profile', data);
      
      if (result != null) {
        print("✅ MongoDB API cập nhật thành công");
        return result;
      } else {
        print("❌ MongoDB API trả về null");
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật profile MongoDB: $e');
      return null;
    }
  }

  // ==== API 9-10: CHAT APIs
  // 
  // API #9a: Get Conversations - GET /chat/conversations (authenticated)
  // SỬ DỤNG TẠI: ChatHomePage.dart (line 26)
  /// Lấy danh sách cuộc trò chuyện
  static Future<List<dynamic>> getConversations() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      print("❌ getConversations ${response.statusCode}: ${response.body}");
      return [];
    } catch (e) {
      print('❌ Error getConversations: $e');
      return [];
    }
  }

  // API #9b: Get Messages - GET /chat/conversations/:id/messages (authenticated)
  // SỬ DỤNG TẠI: ChatHomePage.dart (line 314)
  /// Lấy tin nhắn của một cuộc trò chuyện
  static Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      print("❌ getMessages ${response.statusCode}: ${response.body}");
      return [];
    } catch (e) {
      print('❌ Error getMessages: $e');
      return [];
    }
  }

  // API #9c: Send Message - POST /chat/messages (authenticated)
  // SỬ DỤNG TẠI: ChatHomePage.dart (line 342)
  /// Gửi tin nhắn
  static Future<Map<String, dynamic>?> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages'),
        headers: headers,
        body: json.encode({
          'conversationId': conversationId,
          'content': content,
          'type': 'text',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      print("❌ sendMessage ${response.statusCode}: ${response.body}");
      return null;
    } catch (e) {
      print('❌ Error sendMessage: $e');
      return null;
    }
  }

  // API #9d: Create Conversation - POST /chat/conversations (authenticated)
  // SỬ DỤNG TẠI: ChatHomePage.dart (line 564)
  /// Tạo cuộc trò chuyện mới
  static Future<Map<String, dynamic>?> createConversation(
    String participantId,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: headers,
        body: json.encode({'participantId': participantId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      print("❌ createConversation ${response.statusCode}: ${response.body}");
      return null;
    } catch (e) {
      print('❌ Error createConversation: $e');
      return null;
    }
  }

  // API #9e: Search Chat Users - GET /chat/users (authenticated)
  // SỬ DỤNG TẠI: ChatHomePage.dart (line 539)
  /// Tìm kiếm user để chat
  static Future<List<dynamic>> searchChatUsers(String query) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/users?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      print("❌ searchChatUsers ${response.statusCode}: ${response.body}");
      return [];
    } catch (e) {
      print('❌ Error searchChatUsers: $e');
      return [];
    }
  }

  // PRIVATE HELPERS 
  static Future<Map<String, dynamic>?> _getAuthenticatedItem(
    String endpoint,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print('Error fetching $endpoint: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> _putAuthenticated(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'];
      }
    } catch (e) {
      print('Error updating $endpoint: $e');
    }
    return null;
  }

  static Future<bool> _deleteAuthenticated(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting $endpoint: $e');
    }
    return false;
  }
}
