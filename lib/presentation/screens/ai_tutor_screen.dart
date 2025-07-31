import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/services/ai_service.dart';
import '../utils/responsive_helper.dart';


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

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
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
        text: 'Hello! I\'m your AI tutor. I can help you with any UTME subject. What would you like to learn today?',
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
    _scrollToBottom();
  }
});

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



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'AI Tutor',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedSubject = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _subjects.map((String subject) {
                return PopupMenuItem<String>(
                  value: subject,
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    ),
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedSubject,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveHelper.responsiveColumn(
        context: context,
        children: [
          // Chat Messages
          Expanded(
            child: _buildChatMessages(context, isDark),
          ),
          
          // Input Section
          _buildInputSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildChatMessages(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
      controller: _scrollController,
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator(context, isDark);
        }
        
        final message = _messages[index];
        return _buildMessageBubble(context, message, isDark);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsivePadding(context)),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: ResponsiveHelper.getResponsiveIconSize(context, 16),
              backgroundColor: AppColors.dominantPurple,
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 16),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsivePadding(context) / 2),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.screenWidth(context) * 0.75,
              ),
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.dominantPurple
                    : isDark
                        ? const Color(0xFF23243B)
                        : Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      color: isUser ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 4),
                  
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      color: isUser 
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: ResponsiveHelper.getResponsivePadding(context) / 2),
            CircleAvatar(
              radius: ResponsiveHelper.getResponsiveIconSize(context, 16),
              backgroundColor: AppColors.accentAmber,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsivePadding(context)),
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveHelper.getResponsiveIconSize(context, 16),
            backgroundColor: AppColors.dominantPurple,
            child: Icon(
              Icons.psychology,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, 16),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context) / 2),
          
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(context, 0),
                _buildTypingDot(context, 1),
                _buildTypingDot(context, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(BuildContext context, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.dominantPurple,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, bool isDark) {
    return Container(
      padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23243B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A20) : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                border: Border.all(
                  color: AppColors.textTertiary,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about $_selectedSubject...',
                  hintStyle: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
          
          Container(
            decoration: BoxDecoration(
              color: AppColors.dominantPurple,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
