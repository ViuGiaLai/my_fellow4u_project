import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/models/trip.dart';

void main() {
  group('Trip Model Tests', () {
    test('fromJson should parse JSON correctly', () {
      final json = {
        'id': 'trip_123',
        'title': 'Tokyo Adventure',
        'destination': 'Tokyo, Japan',
        'startDate': '2024-06-01T00:00:00.000Z',
        'endDate': '2024-06-10T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '18:00',
        'travelerCount': 4,
        'maxBudget': 5000.0,
        'requiredLanguages': ['English', 'Japanese'],
        'imageUrl': 'https://example.com/trip.jpg',
        'userId': 'user_123',
        'status': 'confirmed',
        'host': {'name': 'John Doe'},
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, 'trip_123');
      expect(trip.title, 'Tokyo Adventure');
      expect(trip.destination, 'Tokyo, Japan');
      expect(trip.travelerCount, 4);
      expect(trip.maxBudget, 5000.0);
      expect(trip.requiredLanguages, ['English', 'Japanese']);
      expect(trip.status, 'confirmed');
      expect(trip.hostName, 'John Doe');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final trip = Trip.fromJson(json);

      expect(trip.id, isNull);
      expect(trip.title, '');
      expect(trip.destination, '');
      expect(trip.travelerCount, 1);
      expect(trip.requiredLanguages, isEmpty);
    });

    test('fromJson should handle _id field', () {
      final json = {
        '_id': 'trip_456',
        'title': 'Test Trip',
        'destination': 'Test',
        'startDate': '2024-06-01T00:00:00.000Z',
        'endDate': '2024-06-10T00:00:00.000Z',
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, 'trip_456');
    });

    test('toJson should convert to JSON correctly', () {
      final trip = Trip(
        id: 'trip_123',
        title: 'Tokyo Adventure',
        destination: 'Tokyo, Japan',
        startDate: DateTime.parse('2024-06-01'),
        endDate: DateTime.parse('2024-06-10'),
        travelerCount: 4,
        maxBudget: 5000.0,
        requiredLanguages: ['English'],
        status: 'confirmed',
      );

      final json = trip.toJson();

      expect(json['id'], 'trip_123');
      expect(json['title'], 'Tokyo Adventure');
      expect(json['destination'], 'Tokyo, Japan');
      expect(json['travelerCount'], 4);
      expect(json['maxBudget'], 5000.0);
      expect(json['requiredLanguages'], ['English']);
      expect(json['status'], 'confirmed');
    });

    test('toJson should not include null values', () {
      final trip = Trip(
        title: 'Test Trip',
        destination: 'Test',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final json = trip.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('maxBudget'), isFalse);
      expect(json.containsKey('imageUrl'), isFalse);
    });

    test('toWishlistMap should convert correctly', () {
      final trip = Trip(
        id: 'trip_123',
        title: 'Test Trip',
        destination: 'Test',
        startDate: DateTime.parse('2024-06-01'),
        endDate: DateTime.parse('2024-06-10'),
        imageUrl: 'https://example.com/img.jpg',
        hostName: 'John',
      );

      final map = trip.toWishlistMap();

      expect(map['_id'], 'trip_123');
      expect(map['title'], 'Test Trip');
      expect(map['thumbnail'], 'https://example.com/img.jpg');
      expect(map['host'], {'name': 'John'});
    });

    test('copyWith should create a copy with updated values', () {
      final trip = Trip(
        id: 'trip_123',
        title: 'Original Title',
        destination: 'Original',
        startDate: DateTime.parse('2024-06-01'),
        endDate: DateTime.parse('2024-06-10'),
        travelerCount: 2,
      );

      final updated = trip.copyWith(
        title: 'Updated Title',
        travelerCount: 5,
      );

      expect(updated.id, 'trip_123');
      expect(updated.title, 'Updated Title');
      expect(updated.destination, 'Original');
      expect(updated.travelerCount, 5);
    });

    test('toString should return formatted string', () {
      final trip = Trip(
        id: 'trip_123',
        title: 'Test Trip',
        destination: 'Tokyo',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final result = trip.toString();

      expect(result, contains('trip_123'));
      expect(result, contains('Test Trip'));
      expect(result, contains('Tokyo'));
    });
  });
}