import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/models/conversation.dart';

void main() {
  group('Conversation Model Tests', () {
    test('fromJson should parse flat JSON correctly', () {
      final json = {
        'id': 'conv_123',
        'participantId': 'user_456',
        'participantName': 'John Doe',
        'participantAvatarUrl': 'https://example.com/avatar.jpg',
        'lastMessage': 'Hello!',
        'lastMessageAt': '2024-01-01T12:00:00.000Z',
        'unreadCount': 3,
        'createdAt': '2024-01-01T10:00:00.000Z',
      };

      final conv = Conversation.fromJson(json);

      expect(conv.id, 'conv_123');
      expect(conv.participantId, 'user_456');
      expect(conv.participantName, 'John Doe');
      expect(conv.participantAvatarUrl, 'https://example.com/avatar.jpg');
      expect(conv.lastMessage, 'Hello!');
      expect(conv.unreadCount, 3);
    });

    test('fromJson should parse nested participant correctly', () {
      final json = {
        'id': 'conv_123',
        'participant': {
          '_id': 'user_456',
          'firstName': 'John',
          'lastName': 'Doe',
          'avatar': 'https://example.com/avatar.jpg',
        },
        'lastMessage': 'Hi there',
        'lastMessageAt': '2024-01-01T12:00:00.000Z',
      };

      final conv = Conversation.fromJson(json);

      expect(conv.participantId, 'user_456');
      expect(conv.participantName, 'John Doe');
      expect(conv.participantAvatarUrl, 'https://example.com/avatar.jpg');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final conv = Conversation.fromJson(json);

      expect(conv.id, isNull);
      expect(conv.participantId, isNull);
      expect(conv.participantName, isNull);
      expect(conv.unreadCount, 0);
    });

    test('toJson should convert to JSON correctly', () {
      final conv = Conversation(
        id: 'conv_123',
        participantId: 'user_456',
      );

      final json = conv.toJson();

      expect(json['id'], 'conv_123');
      expect(json['participantId'], 'user_456');
    });

    test('copyWith should create a copy with updated values', () {
      final conv = Conversation(
        id: 'conv_123',
        participantName: 'Original Name',
        unreadCount: 0,
      );

      final updated = conv.copyWith(
        participantName: 'Updated Name',
        unreadCount: 5,
      );

      expect(updated.id, 'conv_123');
      expect(updated.participantName, 'Updated Name');
      expect(updated.unreadCount, 5);
    });

    test('toString should return formatted string', () {
      final conv = Conversation(
        id: 'conv_123',
        participantName: 'John Doe',
      );

      final result = conv.toString();

      expect(result, contains('conv_123'));
      expect(result, contains('John Doe'));
    });
  });

  group('Message Model Tests', () {
    test('fromJson should parse flat JSON correctly', () {
      final json = {
        'id': 'msg_123',
        'conversationId': 'conv_456',
        'senderId': 'user_789',
        'senderName': 'John Doe',
        'content': 'Hello!',
        'type': 'text',
        'createdAt': '2024-01-01T12:00:00.000Z',
      };

      final msg = Message.fromJson(json);

      expect(msg.id, 'msg_123');
      expect(msg.conversationId, 'conv_456');
      expect(msg.senderId, 'user_789');
      expect(msg.senderName, 'John Doe');
      expect(msg.content, 'Hello!');
      expect(msg.type, 'text');
    });

    test('fromJson should parse nested sender correctly', () {
      final json = {
        'id': 'msg_123',
        'sender': {
          '_id': 'user_456',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
        },
        'content': 'Test message',
      };

      final msg = Message.fromJson(json);

      expect(msg.senderId, 'user_456');
      expect(msg.senderName, 'John Doe');
    });

    test('fromJson should handle null content', () {
      final json = <String, dynamic>{};

      final msg = Message.fromJson(json);

      expect(msg.content, '');
    });

    test('toJson should convert to JSON correctly', () {
      final msg = Message(
        id: 'msg_123',
        conversationId: 'conv_456',
        content: 'Hello!',
        type: 'text',
      );

      final json = msg.toJson();

      expect(json['id'], 'msg_123');
      expect(json['conversationId'], 'conv_456');
      expect(json['content'], 'Hello!');
      expect(json['type'], 'text');
    });

    test('copyWith should create a copy with updated values', () {
      final msg = Message(
        id: 'msg_123',
        content: 'Original',
        isMe: false,
      );

      final updated = msg.copyWith(
        content: 'Updated',
        isMe: true,
      );

      expect(updated.id, 'msg_123');
      expect(updated.content, 'Updated');
      expect(updated.isMe, true);
    });

    test('toString should return formatted string', () {
      final msg = Message(
        id: 'msg_123',
        content: 'Test message',
      );

      final result = msg.toString();

      expect(result, contains('msg_123'));
      expect(result, contains('Test message'));
    });
  });
}