// SỬ DỤNG TẠI: user_repository.dart, profile_screen.dart, edit_profile_screen.dart, settings_screen.dart
class User {
  final String? id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String? address;
  final List<String> languages;
  final List<String> interests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.address,
    this.languages = const [],
    this.interests = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Parse JSON → Model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (bio != null) 'bio': bio,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'languages': languages,
      'interests': interests,
    };
  }

  /// Copy with
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    String? phone,
    String? address,
    List<String>? languages,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}