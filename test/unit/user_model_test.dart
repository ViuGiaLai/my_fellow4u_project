import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('fromJson should parse JSON correctly', () {
      final json = {
        'id': 'user_123',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'bio': 'Test bio',
        'phone': '+1234567890',
        'address': 'Test Address',
        'languages': ['English', 'Vietnamese'],
        'interests': ['Travel', 'Photography'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user_123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.bio, 'Test bio');
      expect(user.phone, '+1234567890');
      expect(user.address, 'Test Address');
      expect(user.languages, ['English', 'Vietnamese']);
      expect(user.interests, ['Travel', 'Photography']);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final user = User.fromJson(json);

      expect(user.id, isNull);
      expect(user.email, isNull);
      expect(user.name, isNull);
      expect(user.languages, isEmpty);
      expect(user.interests, isEmpty);
    });

    test('toJson should convert to JSON correctly', () {
      final user = User(
        id: 'user_123',
        email: 'test@example.com',
        name: 'Test User',
        languages: ['English'],
        interests: ['Travel'],
      );

      final json = user.toJson();

      expect(json['id'], 'user_123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['languages'], ['English']);
      expect(json['interests'], ['Travel']);
    });

    test('toJson should not include null values', () {
      final user = User(name: 'Test User');

      final json = user.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('email'), isFalse);
      expect(json['name'], 'Test User');
    });

    test('copyWith should create a copy with updated values', () {
      final user = User(
        id: 'user_123',
        name: 'Original Name',
        email: 'original@example.com',
      );

      final updatedUser = user.copyWith(
        name: 'Updated Name',
        bio: 'New bio',
      );

      expect(updatedUser.id, 'user_123');
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.email, 'original@example.com');
      expect(updatedUser.bio, 'New bio');
    });

    test('copyWith should preserve original values when not specified', () {
      final user = User(
        id: 'user_123',
        name: 'Test User',
        email: 'test@example.com',
        languages: ['English'],
      );

      final copy = user.copyWith();

      expect(copy.id, user.id);
      expect(copy.name, user.name);
      expect(copy.email, user.email);
      expect(copy.languages, user.languages);
    });

    test('toString should return formatted string', () {
      final user = User(id: 'user_123', name: 'Test User', email: 'test@example.com');

      final result = user.toString();

      expect(result, contains('user_123'));
      expect(result, contains('Test User'));
      expect(result, contains('test@example.com'));
    });
  });
}