import 'package:flutter/material.dart';
import '../services/api_service.dart';

Color primary = const Color(0xff2ED1B2);

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final conversations = await ApiService.getConversations();
    setState(() {
      _conversations = conversations;
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) {
      final participant = conv['participant'] ?? {};
      final name =
          "${participant['firstName'] ?? ''} ${participant['lastName'] ?? ''}"
              .toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── HEADER ──
          Stack(
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://res.cloudinary.com/dqe5syxc0/image/upload/v1769696289/Mask_Group_mejmh6.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                bottom: 60,
                child: Text(
                  "Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 16,
                right: 16,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: "Search Chat",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── CHAT LIST ──
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conv = _filteredConversations[index];
                          final participant = conv['participant'] ?? {};
                          final name =
                              "${participant['firstName'] ?? ''} ${participant['lastName'] ?? ''}"
                                  .trim();
                          final avatar = participant['avatar'] as String?;
                          final lastMessage =
                              conv['lastMessage'] as String? ?? '';
                          final lastTime = conv['updatedAt'] as String?;

                          return _ChatItem(
                            name: name.isEmpty ? 'Unknown' : name,
                            message: lastMessage,
                            avatarUrl: avatar,
                            time: _formatTime(lastTime),
                            conversationId: conv['_id'] as String,
                            participantId: participant['_id'] as String,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    conversationId: conv['_id'] as String,
                                    participantId: participant['_id'] as String,
                                    participantName: name.isEmpty ? 'Unknown' : name,
                                    participantAvatar: avatar,
                                  ),
                                ),
                              );
                              await _loadConversations();
                            },
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_add_friend_fab',
        backgroundColor: primary,
        child: const Icon(Icons.person_add),
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>?>(
            context,
            MaterialPageRoute(builder: (_) => const AddFriendScreen()),
          );

          if (result?['refresh'] == true) {
            await _loadConversations();
          }

          final conversationId = result?['conversationId'] as String?;
          final participantId = result?['participantId'] as String?;
          final participantName = result?['participantName'] as String?;
          final participantAvatar = result?['participantAvatar'] as String?;

          if (conversationId != null && participantId != null && participantName != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  conversationId: conversationId,
                  participantId: participantId,
                  participantName: participantName,
                  participantAvatar: participantAvatar,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No conversations yet",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadConversations,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      return "${dt.day}/${dt.month}";
    } catch (_) {
      return '';
    }
  }
}

// ── Chat Item Widget ──────────────────────────────────────────────────────────

class _ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String? avatarUrl;
  final String time;
  final String conversationId;
  final String participantId;
  final Future<void> Function()? onTap;

  const _ChatItem({
    required this.name,
    required this.message,
    required this.avatarUrl,
    required this.time,
    required this.conversationId,
    required this.participantId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
          avatarUrl ??
              "https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png",
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        message.isNotEmpty ? message : 'Start a conversation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}

// ── Chat Detail 

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String? participantAvatar;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ID của user hiện tại - lấy từ Supabase
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    final messages = await ApiService.getMessages(widget.conversationId);

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final newMessage = await ApiService.sendMessage(
      widget.conversationId,
      content,
    );

    setState(() => _isSending = false);

    if (newMessage != null) {
      setState(() => _messages.add(newMessage));
      _scrollToBottom();
    }
  }

  bool _isMyMessage(Map<dynamic, dynamic> msg) {
    final sender = msg['sender'] ?? {};
    final senderId = sender['_id']?.toString() ?? sender['id']?.toString();
    return senderId != widget.participantId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                widget.participantAvatar ??
                    "https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png",
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.participantName),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Messages ──
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? const Center(
                      child: Text(
                        "No messages yet. Say hello! 👋",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _MessageBubble(
                          text: msg['content'] ?? '',
                          isMe: _isMyMessage(msg),
                        );
                      },
                    ),
          ),

          // ── Input ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble 

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? primary : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ── Add Friend ────────────────────────────────────────────────────────────────

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  bool _isCreating = false;
  final Map<String, bool> _selected = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers([String query = '']) async {
    setState(() => _isLoading = true);
    final users = await ApiService.searchChatUsers(query);
    setState(() {
      _users = users;
      for (final user in users) {
        _selected.putIfAbsent(user['_id'] as String, () => false);
      }
      _isLoading = false;
    });
  }

  Future<void> _createConversations() async {
    final selectedIds =
        _selected.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one person")),
      );
      return;
    }

    setState(() => _isCreating = true);

    final createdConversations = <Map<String, dynamic>>[];
    for (final id in selectedIds) {
      final conversation = await ApiService.createConversation(id);
      if (conversation != null) {
        createdConversations.add(conversation);
      }
    }

    setState(() => _isCreating = false);

    if (!mounted) return;

    final singleParticipant = selectedIds.length == 1
        ? _users.firstWhere(
            (user) => user['_id'] == selectedIds.first,
            orElse: () => null,
          )
        : null;

    final result = <String, dynamic>{'refresh': true};

    if (singleParticipant != null && createdConversations.isNotEmpty) {
      final createdConversation = createdConversations.first;
      result.addAll({
        'conversationId': createdConversation['_id'] as String?,
        'participantId': singleParticipant['_id'] as String?,
        'participantName': "${singleParticipant['firstName'] ?? ''} ${singleParticipant['lastName'] ?? ''}".trim(),
        'participantAvatar': singleParticipant['avatar'] as String?,
      });
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Conversation"),
        actions: [
          _isCreating
              ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : TextButton(
                onPressed: _createConversations,
                child: Text(
                  "DONE",
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
              ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search people...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => _loadUsers(v),
            ),
          ),
          // User list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                    ? const Center(child: Text("No users found"))
                    : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final uid = user['_id'] as String;
                        return CheckboxListTile(
                          value: _selected[uid] ?? false,
                          activeColor: primary,
                          title: Text(
                            "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
                                .trim(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          secondary: CircleAvatar(
                            backgroundImage: NetworkImage(
                              user['avatar'] as String? ??
                                  "https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png",
                            ),
                          ),
                          onChanged: (v) => setState(() => _selected[uid] = v!),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
