import 'package:flutter/material.dart';

import '../../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();

  final ChatbotService _chatbotService = ChatbotService();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      "text":
          "🌾 Hello! I’m Agrii AI.\n\nHow can I help you with your farming today?",
      "isUser": false,
    },
  ];

  bool _isLoading = false;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SEND MESSAGE
  // ==========================================================

  Future<void> sendMessage() async {
    if (_isLoading) {
      return;
    }

    final String userMessage = _controller.text.trim();

    if (userMessage.isEmpty) {
      return;
    }

    // ========================================================
    // ADD USER MESSAGE
    // ========================================================

    setState(() {
      messages.add({"text": userMessage, "isUser": true});

      _isLoading = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {
      // ======================================================
      // SEND TO BACKEND
      // ======================================================

      final String reply = await _chatbotService.sendMessage(userMessage);

      if (!mounted) {
        return;
      }

      // ======================================================
      // ADD AI RESPONSE
      // ======================================================

      setState(() {
        messages.add({"text": reply, "isUser": false});

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Chatbot screen error: $e");

      if (!mounted) {
        return;
      }

      setState(() {
        messages.add({
          "text": "Unable to connect to Agrii AI. Please try again.",
          "isUser": false,
        });

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // ==========================================================
  // SCROLL TO BOTTOM
  // ==========================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ==========================================================
  // MESSAGE BUBBLE
  // ==========================================================

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isUser = message["isUser"] == true;

    final String text = message["text"]?.toString() ?? "";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 17,
            height: 1.55,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // LOADING INDICATOR
  // ==========================================================

  Widget _buildLoading() {
    if (!_isLoading) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Agrii AI is thinking...",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        title: const Text(
          "Agrii AI Chatbot",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // MESSAGES
            // ==================================================
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(15, 18, 15, 15),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(messages[index]);
                },
              ),
            ),

            // ==================================================
            // LOADING
            // ==================================================
            _buildLoading(),

            // ==================================================
            // INPUT AREA
            // ==================================================
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              color: Colors.white,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ============================================
                  // TEXT FIELD
                  // ============================================
                  Expanded(
                    child: TextField(
                      controller: _controller,

                      minLines: 1,
                      maxLines: 5,

                      textInputAction: TextInputAction.send,

                      onSubmitted: (_) {
                        sendMessage();
                      },

                      decoration: InputDecoration(
                        hintText: "Ask about farming...",

                        hintStyle: const TextStyle(color: Colors.grey),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ============================================
                  // SEND BUTTON
                  // ============================================
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange,

                    child: IconButton(
                      onPressed: _isLoading ? null : sendMessage,

                      icon: Icon(
                        Icons.send_rounded,
                        color: _isLoading ? Colors.white54 : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
