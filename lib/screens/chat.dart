import 'package:chat_app/models/chatmsg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../widgets/msg_bubble.dart';
import 'login.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatModel> messages = [];
  bool _showDrawer = false;

  @override
  void initState() {
    super.initState();
    // Add initial message
    messages.add(
      ChatModel(
        text: 'How can I help you?',
        isUser: false,
        //timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatModel(
          text: _messageController.text,
          isUser: true,
          //timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate bot response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add(
          ChatModel(
            text: 'This is a sample response from the bot.',
            isUser: false,
            //timestamp: DateTime.now(),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _regenerateLastBotMessage(int messageIndex) {
    setState(() {
      messages[messageIndex] = ChatModel(
        text: 'This is a regenerated response from the bot.',
        isUser: false,
        //timestamp: DateTime.now(),
      );
    });

    // Optional: Show loading indicator and simulate API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response regenerated'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF333333),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.27, 0.67, 0.90],
            colors: [
              Color(0xFF000000), // 27% - #000000
              Color(0xFF1E1E1E), // 67% - #1E1E1E
              Color(0xFF666666), // 90% - #666666
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.only(
                    top: 48,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/Menu.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showDrawer = !_showDrawer;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse('https://gbu.ac.in');
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open gbu site'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Color(0xFF333333),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFF333333),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Messages Area
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text(
                            'How can I help you?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: messages[index],
                              onRegenerate: messages[index].isUser
                                  ? null
                                  : () => _regenerateLastBotMessage(index),
                            );
                          },
                        ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Enter query here...',
                            filled: true,
                            fillColor: const Color(0xFF2D2D2D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(
                              color: Color(0xFF888888),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          iconSize: 24,
                          onPressed: _sendMessage,
                          tooltip: 'Send message',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Side Drawer
            if (_showDrawer)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showDrawer = false;
                  });
                },
                child: Container(color: Colors.black54),
              ),

            if (_showDrawer)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 250,
                  color: const Color(0xFF1A1A1A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'UserID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF333333),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
