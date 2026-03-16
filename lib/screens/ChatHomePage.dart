import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

Color primary = const Color(0xff2ED1B2);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat UI",
      theme: ThemeData(useMaterial3: true),
      home: const ChatListScreen(),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// HEADER IMAGE
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
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search Chat",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// CHAT LIST
          Expanded(
            child: ListView(
              children: [
                chatItem(context, "Tuan Tran", "It's a beautiful place"),
                chatItem(context, "Emmy", "We can start at 8am"),
                chatItem(context, "Khai Ho", "See you tomorrow"),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFriend()),
          );
        },
      ),
    );
  }

  Widget chatItem(BuildContext context, String name, String message) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
          "https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png",
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: const Text("10:30 AM", style: TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatDetail()),
        );
      },
    );
  }
}

class ChatDetail extends StatelessWidget {
  const ChatDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emmy"),
        centerTitle: true,
        actions: const [Icon(Icons.add_circle_outline), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// DATE
          const Text("Jan 30, 2020", style: TextStyle(color: Colors.grey)),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                MessageBubble(text: "Hi, this is Emmy", isMe: true),
                MessageBubble(
                  text:
                      "It is a long established fact that a reader will be distracted",
                  isMe: true,
                ),
                MessageBubble(
                  text: "as opposed to using 'Content here'",
                  isMe: false,
                ),
                MessageBubble(
                  text: "There are many variations of passages",
                  isMe: false,
                ),
              ],
            ),
          ),

          /// INPUT
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.mic),
                const SizedBox(width: 10),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Type message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceMessage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  Map<String, bool> selected = {
    "Pena Valdez": false,
    "Gil Hjoon": false,
    "Fitzgerald": false,
    "KeriBerber": false,
    "WhiteCastaneda": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFriendDone()),
              );
            },
            child: const Text("DONE"),
          ),
        ],
      ),
      body: ListView(
        children:
            selected.keys.map((name) {
              return CheckboxListTile(
                value: selected[name],
                title: Text(name),
                secondary: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/3.jpg",
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    selected[name] = v!;
                  });
                },
              );
            }).toList(),
      ),
    );
  }
}

class AddFriendDone extends StatelessWidget {
  const AddFriendDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Added")),
      body: const Center(
        child: Icon(Icons.check_circle, color: Colors.green, size: 100),
      ),
    );
  }
}

class VoiceMessage extends StatelessWidget {
  const VoiceMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Message")),
      body: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          child: const Icon(Icons.mic, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
