import 'dart:convert'; // For encoding/decoding messages
import 'package:shared_preferences/shared_preferences.dart';
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

  static const String _chatHistoryKey = 'ai_tutor_chat_history';

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
    _saveChatHistory(); // Save after user message

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
        _saveChatHistory(); // Save after AI response
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

  Widget _buildMessage(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userBubbleColor = AppColors.dominantPurple;
    final aiBubbleColor = AppColors.backgroundPrimary;
    final userTextColor = Colors.white;
    final aiTextColor = AppColors.textPrimary;
    
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dominantPurple,
                    AppColors.dominantPurple.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dominantPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: message.isUser ? userBubbleColor : aiBubbleColor,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(6),
                  bottomRight: message.isUser
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? AppColors.dominantPurple.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: message.isUser
                    ? null
                    : Border.all(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
              ),
              child: message.isUser 
                ? Text(
                    message.text,
                    style: TextStyle(
                      color: userTextColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                : _buildFormattedText(message.text, aiTextColor),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentAmber,
                    AppColors.accentAmber.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentAmber.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, Color textColor) {
    // Parse the text and create formatted spans
    List<TextSpan> spans = [];
    
    // Split text into lines for processing
    List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) {
        // Add spacing for empty lines
        spans.add(TextSpan(text: '\n', style: TextStyle(height: 1.5)));
        continue;
      }
      
      // Check for different formatting patterns
      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        // Bold text (headers) - must be more than just "**"
        String content = line.substring(2, line.length - 2);
        spans.add(TextSpan(
          text: '$content\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
            height: 1.6,
          ),
        ));
        // Add extra spacing after headers
        spans.add(TextSpan(text: '\n', style: TextStyle(height: 1.2)));
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        // Bullet points
        String content = line.substring(2);
        spans.add(TextSpan(
          text: '  • ',
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            height: 1.4,
          ),
        ));
        // Add the content with inline formatting
        spans.addAll(_parseInlineFormatting(content, textColor));
        spans.add(TextSpan(text: '\n'));
      } else if (line.startsWith('**') && line.contains(':**')) {
        // Bold labels (like "**Angle of Incidence:**")
        int colonIndex = line.indexOf(':**');
        String label = line.substring(2, colonIndex);
        String content = line.substring(colonIndex + 3);
        spans.add(TextSpan(
          text: '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: textColor,
            height: 1.4,
          ),
        ));
        // Add the content with inline formatting
        spans.addAll(_parseInlineFormatting(content, textColor));
        spans.add(TextSpan(text: '\n'));
      } else if (line.contains('**') && line.contains('**')) {
        // Inline bold text - improved parsing
        spans.addAll(_parseInlineFormatting(line, textColor));
        spans.add(TextSpan(text: '\n'));
      } else if (line.contains('sin(') || line.contains('cos(') || line.contains('tan(') || 
                 line.contains('n₁') || line.contains('n₂') || line.contains('n<sub>')) {
        // Mathematical formulas
        spans.add(TextSpan(
          text: _formatMathematicalText(line, textColor),
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            height: 1.4,
            fontFamily: 'monospace',
          ),
        ));
        spans.add(TextSpan(text: '\n'));
      } else {
        // Regular paragraph text
        spans.add(TextSpan(
          text: '$line\n',
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            height: 1.4,
          ),
        ));
      }
    }
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  List<TextSpan> _parseInlineFormatting(String text, Color textColor) {
    List<TextSpan> spans = [];
    
    // First, handle double asterisks (**text**)
    List<String> parts = text.split('**');
    List<TextSpan> doubleAsteriskSpans = [];
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      if (i % 2 == 0) {
        // Regular text - now check for single asterisks
        doubleAsteriskSpans.addAll(_parseSingleAsterisks(parts[i], textColor));
      } else {
        // Bold text (double asterisks)
        doubleAsteriskSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
            height: 1.4,
          ),
        ));
      }
    }
    
    return doubleAsteriskSpans;
  }

  List<TextSpan> _parseSingleAsterisks(String text, Color textColor) {
    List<TextSpan> spans = [];
    List<String> parts = text.split('*');
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      if (i % 2 == 0) {
        // Regular text
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            height: 1.4,
          ),
        ));
      } else {
        // Bold text (single asterisks)
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
            height: 1.4,
          ),
        ));
      }
    }
    
    return spans;
  }

  String _formatMathematicalText(String text, Color textColor) {
    // Handle mathematical formulas and subscripts
    String result = text;
    
    // Replace n<sub>1</sub> with n₁
    result = result.replaceAll('n<sub>1</sub>', 'n₁');
    result = result.replaceAll('n<sub>2</sub>', 'n₂');
    
    // Replace other common mathematical notations
    result = result.replaceAll('sin(', 'sin(');
    result = result.replaceAll('cos(', 'cos(');
    result = result.replaceAll('tan(', 'tan(');
    
    // Handle other common subscripts
    result = result.replaceAll('<sub>1</sub>', '₁');
    result = result.replaceAll('<sub>2</sub>', '₂');
    result = result.replaceAll('<sub>3</sub>', '₃');
    result = result.replaceAll('<sub>4</sub>', '₄');
    result = result.replaceAll('<sub>5</sub>', '₅');
    result = result.replaceAll('<sub>6</sub>', '₆');
    result = result.replaceAll('<sub>7</sub>', '₇');
    result = result.replaceAll('<sub>8</sub>', '₈');
    result = result.replaceAll('<sub>9</sub>', '₉');
    result = result.replaceAll('<sub>0</sub>', '₀');
    
    // Handle superscripts
    result = result.replaceAll('<sup>2</sup>', '²');
    result = result.replaceAll('<sup>3</sup>', '³');
    result = result.replaceAll('<sup>4</sup>', '⁴');
    result = result.replaceAll('<sup>5</sup>', '⁵');
    result = result.replaceAll('<sup>6</sup>', '⁶');
    result = result.replaceAll('<sup>7</sup>', '⁷');
    result = result.replaceAll('<sup>8</sup>', '⁸');
    result = result.replaceAll('<sup>9</sup>', '⁹');
    result = result.replaceAll('<sup>0</sup>', '⁰');
    result = result.replaceAll('<sup>1</sup>', '¹');
    
    return result;
  }

  Future<void> _saveChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> encoded = _messages.map((msg) => jsonEncode({
    'text': msg.text,
    'isUser': msg.isUser,
    'timestamp': msg.timestamp.toIso8601String(),
  })).toList();
  await prefs.setStringList(_chatHistoryKey, encoded);
}

Future<void> _loadChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? encoded = prefs.getStringList(_chatHistoryKey);
  if (encoded != null) {
    setState(() {
      _messages.clear();
      _messages.addAll(encoded.map((msg) {
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
