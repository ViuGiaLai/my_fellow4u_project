// SỬ DỤNG TẠI: chat_repository.dart, ChatHomePage.dart
class Conversation {
  final String? id;
  final String? participantId;
  final String? participantName;
  final String? participantAvatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? createdAt;

  Conversation({
    this.id,
    this.participantId,
    this.participantName,
    this.participantAvatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.createdAt,
  });

  /// Parse JSON → Model (flat API fields and backend shape with `_id` + `participant`).
  factory Conversation.fromJson(Map<String, dynamic> json) {
    String? participantId;
    String? participantName;
    String? participantAvatarUrl;

    final p = json['participant'];
    if (p is Map) {
      final pm = Map<String, dynamic>.from(p);
      participantId = pm['_id']?.toString() ?? pm['id']?.toString();
      final fn = pm['firstName'] as String? ?? '';
      final ln = pm['lastName'] as String? ?? '';
      final combined = '$fn $ln'.trim();
      participantName =
          combined.isEmpty ? pm['email'] as String? : combined;
      participantAvatarUrl = pm['avatar'] as String?;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final lastAt =
        parseDate(json['lastMessageAt']) ?? parseDate(json['updatedAt']);

    return Conversation(
      id: json['id'] as String? ?? json['_id']?.toString(),
      participantId:
          participantId ?? json['participantId'] as String?,
      participantName:
          participantName ?? json['participantName'] as String?,
      participantAvatarUrl:
          participantAvatarUrl ?? json['participantAvatarUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: lastAt,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: parseDate(json['createdAt']),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (participantId != null) 'participantId': participantId,
    };
  }

  /// Copy with
  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatarUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatarUrl: participantAvatarUrl ?? this.participantAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Conversation(id: $id, participantName: $participantName)';
}

class Message {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? senderName;
  final String content;
  final String? type;
  final DateTime? createdAt;
  final bool isMe;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    required this.content,
    this.type = 'text',
    this.createdAt,
    this.isMe = false,
  });

  /// Parse JSON → Model (flat fields and Mongoose populate: `sender`, `conversation`).
  factory Message.fromJson(Map<String, dynamic> json, {bool isMe = false}) {
    String? senderId;
    String? senderName;
    final sender = json['sender'];
    if (sender is Map) {
      final sm = Map<String, dynamic>.from(sender);
      senderId = sm['_id']?.toString() ?? sm['id']?.toString();
      final fn = sm['firstName'] as String? ?? '';
      final ln = sm['lastName'] as String? ?? '';
      senderName = '$fn $ln'.trim();
      if (senderName.isEmpty) senderName = sm['email'] as String?;
    } else if (sender != null) {
      senderId = sender.toString();
    }

    final conv = json['conversation'];
    final String? conversationId = conv == null
        ? json['conversationId'] as String?
        : (conv is Map
            ? (conv['_id'] ?? conv['id'])?.toString()
            : conv.toString());

    DateTime? createdAt;
    final ca = json['createdAt'];
    if (ca != null) {
      createdAt =
          ca is DateTime ? ca : DateTime.tryParse(ca.toString());
    }

    return Message(
      id: json['id'] as String? ?? json['_id']?.toString(),
      conversationId: conversationId,
      senderId: senderId ?? json['senderId'] as String?,
      senderName: senderName ?? json['senderName'] as String?,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      createdAt: createdAt,
      isMe: isMe,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (conversationId != null) 'conversationId': conversationId,
      'content': content,
      if (type != null) 'type': type,
    };
  }

  /// Copy with
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    String? type,
    DateTime? createdAt,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
    );
  }

  @override
  String toString() => 'Message(id: $id, content: $content)';
}