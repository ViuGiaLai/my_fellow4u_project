// SỬ DỤNG TẠI: my_photos_screen.dart
import 'dart:typed_data';
import '../models/photo.dart';
import '../services/api_service.dart';

/// Custom exception for Photo errors
class PhotoException implements Exception {
  final String message;
  final int? statusCode;
  
  PhotoException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
  
  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

class PhotoRepository {
  /// Lấy danh sách photos của user
  Future<List<Photo>> getUserPhotos() async {
    try {
      final data = await ApiService.getUserPhotos();
      return data.map((json) => Photo.fromJson(json)).toList();
    } catch (e) {
      throw PhotoException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Upload photo mới
  Future<Photo?> uploadPhoto(
    Uint8List fileBytes,
    String fileName,
    String? description,
  ) async {
    try {
      final data = await ApiService.uploadPhoto(fileBytes, fileName, description);
      if (data != null) {
        return Photo.fromJson(data);
      }
      return null;
    } catch (e) {
      throw PhotoException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Xóa photo
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      return await ApiService.deletePhoto(photoUrl);
    } catch (e) {
      throw PhotoException(_getErrorMessage(e), statusCode: _getStatusCode(e));
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