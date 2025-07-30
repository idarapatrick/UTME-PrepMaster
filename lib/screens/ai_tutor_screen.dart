import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ai_service.dart';
import 'dart:convert'; // For encoding/decoding messages
import 'package:shared_preferences/shared_preferences.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _selectedSubject = 'Mathematics';

  final List<String> _subjects = [
    'Mathematics',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'Literature',
    'Government',
  ];

  static const String _chatHistoryKey = 'chat_history';

  @override
  void initState() {
    super.initState();
    _loadChatHistory().then((_) {
      if (_messages.isEmpty) _addWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Hello! I\'m your AI tutor. I can help you with any UTME subject. What would you like to learn today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });
    _saveChatHistory();

    _scrollToBottom();

    // Simulate AI response
    AIService.getAIResponse(message).then((aiResponse) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _saveChatHistory();
        _scrollToBottom();
      }
    });
  }

  String _generateAiResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('mathematics') || lowerMessage.contains('math')) {
      return 'Great! Let\'s work on Mathematics. What specific topic would you like to focus on? I can help with algebra, calculus, trigonometry, or any other math concepts.';
    } else if (lowerMessage.contains('english')) {
      return 'English is a crucial subject for UTME. I can help you with grammar, comprehension, vocabulary, and essay writing. What area would you like to improve?';
    } else if (lowerMessage.contains('physics')) {
      return 'Physics can be challenging but very rewarding! I can explain concepts like mechanics, electricity, waves, and modern physics. What topic interests you?';
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('struggling')) {
      return 'I\'m here to help! Let me know what specific topic or concept you\'re finding difficult, and I\'ll break it down for you with examples and practice questions.';
    } else if (lowerMessage.contains('practice') ||
        lowerMessage.contains('question')) {
      return 'Practice is key to success! I can provide you with practice questions, explain solutions step-by-step, and help you understand your mistakes. What would you like to practice?';
    } else {
      return 'That\'s an interesting question! I\'d be happy to help you with that. Could you tell me more about what specific aspect you\'d like to learn or practice?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSubjectSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Subject',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    String subject = _subjects[index];
                    bool isSelected = subject == _selectedSubject;

                    return ListTile(
                      leading: Icon(
                        _getSubjectIcon(subject),
                        color: isSelected
                            ? AppColors.dominantPurple
                            : AppColors.textSecondary,
                      ),
                      title: Text(
                        subject,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.dominantPurple
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.dominantPurple,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSubject = subject;
                        });
                        Navigator.pop(context);

                        // Add subject change message
                        _messages.add(
                          ChatMessage(
                            text:
                                'I\'ve switched to $_selectedSubject. How can I help you with this subject?',
                            isUser: false,
                            timestamp: DateTime.now(),
                          ),
                        );
                        _saveChatHistory(); // <-- Add this line
                        _scrollToBottom();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.calculate;
      case 'English':
        return Icons.language;
      case 'Physics':
        return Icons.science;
      case 'Chemistry':
        return Icons.science;
      case 'Biology':
        return Icons.biotech;
      case 'Economics':
        return Icons.trending_up;
      case 'Literature':
        return Icons.book;
      case 'Government':
        return Icons.account_balance;
      default:
        return Icons.school;
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedMessages = _messages.map((msg) => jsonEncode({
          'text': msg.text,
          'isUser': msg.isUser,
          'timestamp': msg.timestamp.toIso8601String(),
        })).toList();
    await prefs.setStringList(_chatHistoryKey, encodedMessages);
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedMessages = prefs.getStringList(_chatHistoryKey);
    if (encodedMessages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(encodedMessages.map((msg) {
          final data = jsonDecode(msg);
          return ChatMessage(
            text: data['text'],
            isUser: data['isUser'],
            timestamp: DateTime.parse(data['timestamp']),
          );
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.subject),
            onPressed: _showSubjectSelector,
            tooltip: 'Change Subject',
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Icon(
                  _getSubjectIcon(_selectedSubject),
                  color: AppColors.dominantPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Currently studying: $_selectedSubject',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.dominantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about $_selectedSubject...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.dominantPurple,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final userBubbleColor = AppColors.dominantPurple;
    final aiBubbleColor = isDark ? cardColor : AppColors.backgroundSecondary;
    final userTextColor = Colors.white;
    final aiTextColor = isDark ? Colors.white : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dominantPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? userBubbleColor : aiBubbleColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? userTextColor : aiTextColor,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentAmber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildDot(0), _buildDot(1), _buildDot(2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
