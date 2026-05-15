import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/services/api_service.dart';

void main() {
  group('ApiException Tests', () {
    test('ApiException should store message and statusCode', () {
      final exception = ApiException('Test error', statusCode: 400);

      expect(exception.message, 'Test error');
      expect(exception.statusCode, 400);
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('400'));
    });

    test('ApiException should handle null statusCode', () {
      final exception = ApiException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'ApiException: Test error');
    });
  });

  group('NetworkException Tests', () {
    test('NetworkException should store message', () {
      final exception = NetworkException('No internet');

      expect(exception.message, 'No internet');
      expect(exception.toString(), 'NetworkException: No internet');
    });
  });

  group('TimeoutException Tests', () {
    test('TimeoutException should store message', () {
      final exception = TimeoutException('Request timeout');

      expect(exception.message, 'Request timeout');
      expect(exception.toString(), 'TimeoutException: Request timeout');
    });
  });

  group('ApiService hasInternet Tests', () {
    test('hasInternet should return bool', () async {
      // This test just verifies the method returns a bool
      // Actual connectivity depends on network state
      final result = await ApiService.hasInternet();

      expect(result, isA<bool>());
    });
  });
}