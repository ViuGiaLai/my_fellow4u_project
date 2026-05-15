// SỬ DỤNG TẠI: photo_repository.dart, my_photos_screen.dart
class Photo {
  final String? id;
  final String url;
  final String? description;
  final String? fileName;
  final String? userId;
  final DateTime? createdAt;

  Photo({
    this.id,
    required this.url,
    this.description,
    this.fileName,
    this.userId,
    this.createdAt,
  });

  /// Parse JSON → Model
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String?,
      url: json['url'] as String? ?? '',
      description: json['description'] as String?,
      fileName: json['fileName'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'url': url,
      if (description != null) 'description': description,
      if (fileName != null) 'fileName': fileName,
    };
  }

  /// Copy with
  Photo copyWith({
    String? id,
    String? url,
    String? description,
    String? fileName,
    String? userId,
    DateTime? createdAt,
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Photo(id: $id, url: $url)';
}