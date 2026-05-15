// SỬ DỤNG TẠI: ChatHomePage.dart
import '../models/conversation.dart';
import '../services/api_service.dart';

/// Custom exception for Chat errors
class ChatException implements Exception {
  final String message;
  final int? statusCode;
  
  ChatException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
  
  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

class ChatRepository {
  /// Lấy danh sách conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final data = await ApiService.getConversations();
      return data
          .map(
            (json) => Conversation.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } catch (e) {
      throw ChatException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Lấy tin nhắn của một conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final data = await ApiService.getMessages(conversationId);
      return data
          .map(
            (json) => Message.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } catch (e) {
      throw ChatException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Gửi tin nhắn
  Future<Message?> sendMessage(String conversationId, String content) async {
    try {
      final data = await ApiService.sendMessage(conversationId, content);
      if (data != null) {
        return Message.fromJson(Map<String, dynamic>.from(data), isMe: true);
      }
      return null;
    } catch (e) {
      throw ChatException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Tạo conversation mới
  Future<Conversation?> createConversation(String participantId) async {
    try {
      final data = await ApiService.createConversation(participantId);
      if (data != null) {
        return Conversation.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      throw ChatException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Tìm kiếm user để chat
  Future<List<Map<String, dynamic>>> searchChatUsers(String query) async {
    try {
      final data = await ApiService.searchChatUsers(query);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw ChatException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Helper: Lấy status code từ exception
  int? _getStatusCode(dynamic e) {
    if (e.toString().contains('401')) return 401;
    if (e.toString().contains('404')) return 404;
    if (e.toString().contains('500')) return 500;
    if (e.toString().contains('502')) return 502;
    if (e.toString().contains('503')) return 503;
    return null;
  }

  /// Helper: Lấy thông báo lỗi thân thiện
  String _getErrorMessage(dynamic e) {
    final errorStr = e.toString().toLowerCase();
    
    if (errorStr.contains('socketexception') || 
        errorStr.contains('connection') ||
        errorStr.contains('network')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra internet!';
    }
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Yêu cầu bị quá thời gian. Vui lòng thử lại!';
    }
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!';
    }
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'Bạn không có quyền thực hiện thao tác này!';
    }
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Không tìm thấy dữ liệu!';
    }
    if (errorStr.contains('500') || errorStr.contains('server error')) {
      return 'Lỗi máy chủ. Vui lòng thử lại sau!';
    }
    if (errorStr.contains('connection refused')) {
      return 'Không thể kết nối máy chủ. Vui lòng thử lại sau!';
    }
    
    return 'Đã xảy ra lỗi. Vui lòng thử lại!';
  }
}