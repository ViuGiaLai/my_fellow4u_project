import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/models/photo.dart';

void main() {
  group('Photo Model Tests', () {
    test('fromJson should parse JSON correctly', () {
      final json = {
        'id': 'photo_123',
        'url': 'https://example.com/photo.jpg',
        'description': 'Beautiful sunset',
        'fileName': 'sunset.jpg',
        'userId': 'user_456',
        'createdAt': '2024-01-01T12:00:00.000Z',
      };

      final photo = Photo.fromJson(json);

      expect(photo.id, 'photo_123');
      expect(photo.url, 'https://example.com/photo.jpg');
      expect(photo.description, 'Beautiful sunset');
      expect(photo.fileName, 'sunset.jpg');
      expect(photo.userId, 'user_456');
      expect(photo.createdAt, isNotNull);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final photo = Photo.fromJson(json);

      expect(photo.id, isNull);
      expect(photo.url, '');
      expect(photo.description, isNull);
      expect(photo.fileName, isNull);
    });

    test('toJson should convert to JSON correctly', () {
      final photo = Photo(
        id: 'photo_123',
        url: 'https://example.com/photo.jpg',
        description: 'Test photo',
        fileName: 'test.jpg',
      );

      final json = photo.toJson();

      expect(json['id'], 'photo_123');
      expect(json['url'], 'https://example.com/photo.jpg');
      expect(json['description'], 'Test photo');
      expect(json['fileName'], 'test.jpg');
    });

    test('toJson should not include null values', () {
      final photo = Photo(url: 'https://example.com/photo.jpg');

      final json = photo.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('fileName'), isFalse);
    });

    test('copyWith should create a copy with updated values', () {
      final photo = Photo(
        id: 'photo_123',
        url: 'https://example.com/old.jpg',
        description: 'Old description',
      );

      final updated = photo.copyWith(
        url: 'https://example.com/new.jpg',
        description: 'New description',
      );

      expect(updated.id, 'photo_123');
      expect(updated.url, 'https://example.com/new.jpg');
      expect(updated.description, 'New description');
    });

    test('toString should return formatted string', () {
      final photo = Photo(
        id: 'photo_123',
        url: 'https://example.com/photo.jpg',
      );

      final result = photo.toString();

      expect(result, contains('photo_123'));
      expect(result, contains('https://example.com/photo.jpg'));
    });
  });
}