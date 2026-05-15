// SỬ DỤNG TẠI: trip_repository.dart, create_trip_page.dart, my_trips_app.dart, trip_info_screen.dart
class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final int travelerCount;
  final double? maxBudget;
  final List<String> requiredLanguages;
  final String? imageUrl;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  /// Backend: waiting | confirmed | completed | cancelled
  final String? status;
  /// Populated host name from API when `host` is an object with `name`.
  final String? hostName;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.travelerCount = 1,
    this.maxBudget,
    this.requiredLanguages = const [],
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.hostName,
  });

  /// Parse JSON → Model
  factory Trip.fromJson(Map<String, dynamic> json) {
    final dynamic hostRaw = json['host'];
    String? hostName;
    if (hostRaw is Map && hostRaw['name'] != null) {
      hostName = hostRaw['name'] as String?;
    }

    return Trip(
      id: json['id'] as String? ?? json['_id']?.toString(),
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      travelerCount: json['travelerCount'] as int? ?? 1,
      maxBudget: (json['maxBudget'] as num?)?.toDouble(),
      requiredLanguages: (json['requiredLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      userId: json['userId'] as String? ?? json['user']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      status: json['status'] as String?,
      hostName: hostName,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'travelerCount': travelerCount,
      if (maxBudget != null) 'maxBudget': maxBudget,
      'requiredLanguages': requiredLanguages,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (status != null) 'status': status,
    };
  }

  /// Shape compatible with wishlist JSON + `_buildTripCard` map branch.
  Map<String, dynamic> toWishlistMap() {
    return {
      '_id': id,
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'thumbnail': imageUrl,
      'imageUrl': imageUrl,
      'status': status,
      if (hostName != null) 'host': {'name': hostName},
    };
  }

  /// Copy with
  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    int? travelerCount,
    double? maxBudget,
    List<String>? requiredLanguages,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? hostName,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      travelerCount: travelerCount ?? this.travelerCount,
      maxBudget: maxBudget ?? this.maxBudget,
      requiredLanguages: requiredLanguages ?? this.requiredLanguages,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      hostName: hostName ?? this.hostName,
    );
  }

  @override
  String toString() => 'Trip(id: $id, title: $title, destination: $destination)';
}