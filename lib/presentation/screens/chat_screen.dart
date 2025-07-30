import 'package:flutter/material.dart';
import '../../domain/models/study_partner.dart';
import '../theme/app_colors.dart';

class ChatMessage {
  final String message;
  final bool isCurrentUser;

  ChatMessage({required this.message, required this.isCurrentUser});
}

class ChatScreen extends StatefulWidget {
  final StudyPartner partner;

  const ChatScreen({Key? key, required this.partner}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add(ChatMessage(message: text.trim(), isCurrentUser: true));
    });
    controller.clear();

    // Simulate reply
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add(ChatMessage(
            message: "Hi, thanks for messaging me!", isCurrentUser: false));
      });
    });
  }

  Widget buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment:
          msg.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: msg.isCurrentUser
              ? AppColors.dominantPurple
              : AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.message,
          style: TextStyle(
            color: msg.isCurrentUser
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Chat with ${widget.partner.name}'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: messages.map(buildMessageBubble).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.dominantPurple),
                  onPressed: () => sendMessage(controller.text),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
