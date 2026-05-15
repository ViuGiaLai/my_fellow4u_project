// SỬ DỤNG TẠI: my_trips_app.dart, create_trip_page.dart, trip_info_screen.dart
import '../models/trip.dart';
import '../services/api_service.dart';

/// Custom exception for Trip errors
class TripException implements Exception {
  final String message;
  final int? statusCode;
  
  TripException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
  
  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

class TripRepository {
  /// Lấy danh sách trips của user
  /// Xử lý: try/catch, timeout, thông báo lỗi
  Future<List<Trip>> getTrips() async {
    try {
      final data = await ApiService.getTrips();
      return data
          .map((json) => Trip.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw TripException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Lấy chi tiết trip theo ID
  Future<Trip?> getTripById(String id) async {
    try {
      final data = await ApiService.getTrip(id);
      if (data != null) {
        return Trip.fromJson(data);
      }
      return null;
    } catch (e) {
      throw TripException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Tạo trip mới
  Future<Trip?> createTrip(Trip trip) async {
    try {
      final data = await ApiService.createTrip(
        title: trip.title,
        destination: trip.destination,
        startDate: trip.startDate,
        endDate: trip.endDate,
        startTime: trip.startTime,
        endTime: trip.endTime,
        travelerCount: trip.travelerCount,
        maxBudget: trip.maxBudget,
        requiredLanguages: trip.requiredLanguages,
        imageUrl: trip.imageUrl,
      );
      if (data != null) {
        return Trip.fromJson(data);
      }
      return null;
    } catch (e) {
      throw TripException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Cập nhật trip
  Future<Trip?> updateTrip(String id, Trip trip) async {
    try {
      final data = await ApiService.updateTrip(id, trip.toJson());
      if (data != null) {
        return Trip.fromJson(data);
      }
      return null;
    } catch (e) {
      throw TripException(_getErrorMessage(e), statusCode: _getStatusCode(e));
    }
  }

  /// Xóa trip
  Future<bool> deleteTrip(String id) async {
    try {
      return await ApiService.deleteTrip(id);
    } catch (e) {
      throw TripException(_getErrorMessage(e), statusCode: _getStatusCode(e));
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