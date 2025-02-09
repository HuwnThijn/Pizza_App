// chat tự cấu hình
// import 'package:flutter/material.dart';
// import 'keyword_responds.dart'; // Ensure this file exists and contains keywords and responses.

// class ChatbotScreen extends StatefulWidget {
//   const ChatbotScreen({super.key});

//   @override
//   State<ChatbotScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatbotScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _textController = TextEditingController();
//   final List<ChatMessage> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the first message with the greeting
//     _messages.add(ChatMessage(
//         text: 'Xin chào! ThreeT kính chào quý khách', isUser: false));
//   }

//   void _scrollDown() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 750),
//         curve: Curves.easeOutCirc,
//       );
//     });
//   }

//   void _sendChatMessage(String message) {
//     if (message.trim().isEmpty) return;

//     setState(() {
//       _messages.add(ChatMessage(text: message, isUser: true));
//     });

//     final response = _getBotResponse(message);

//     setState(() {
//       _messages.add(ChatMessage(text: response, isUser: false));
//       _scrollDown();
//     });

//     _textController.clear();
//   }

//   String _getBotResponse(String userMessage) {
//     // Match keywords in the list to respond
//     for (final keyword in keywords.keys) {
//       if (userMessage.toLowerCase().contains(keyword.toLowerCase())) {
//         return keywords[keyword]!;
//       }
//     }
//     // Return the default response if no match found
//     return responses['default']!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Image.asset(
//             'images/logo5.png',
//             width: 70, // Tăng kích thước logo
//             height: 70,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ChatBubble(message: _messages[index]);
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     onSubmitted: _sendChatMessage,
//                     controller: _textController,
//                     decoration: InputDecoration(
//                       hintText: "Nhập tin nhắn",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => _sendChatMessage(_textController.text),
//                   icon: const Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   ChatMessage({required this.text, required this.isUser});
// }

// class ChatBubble extends StatelessWidget {
//   final ChatMessage message;

//   const ChatBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//       alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//         decoration: BoxDecoration(
//           color: message.isUser ? Colors.blue[200] : Colors.green[200],
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft:
//                 message.isUser ? const Radius.circular(12) : Radius.zero,
//             bottomRight:
//                 message.isUser ? Radius.zero : const Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           message.text,
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }

//chat tự động
import 'package:flutter/material.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mailer/mailer.dart';

const String _apiKey = "AIzaSyDOdQ1inYtf1eMmrGhkjDa70zfn0u6FScg";

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  State<ChatbotScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<ChatbotScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _message = [];

  void initState() {
    super.initState();
    _model = GenerativeModel(model: "gemini-1.5-flash", apiKey: _apiKey);
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 750),
          curve: Curves.easeOutCirc),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _message.add(ChatMessage(text: message, isUser: true));
    });
    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      setState(() {
        _message.add(ChatMessage(text: text!, isUser: false));
        _scrollDown();
      });
    } catch (e) {
      setState(() {
        _message.add(ChatMessage(text: "Error occured", isUser: false));
      });
    } finally {
      _textController.clear();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'images/logo5.png',
            width: 70, // Tăng kích thước logo
            height: 70,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _message.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: _message[index]);
                  })),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  onSubmitted: _sendChatMessage,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Enter a message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
                IconButton(
                  onPressed: () => _sendChatMessage(_textController.text),
                  icon: Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.25,
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
            color: message.isUser ? Colors.blue[200] : Colors.green[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: message.isUser ? Radius.circular(12) : Radius.zero,
              bottomRight: message.isUser ? Radius.zero : Radius.circular(12),
            )),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
