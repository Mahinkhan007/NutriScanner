import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ChatPage extends StatefulWidget {
  final String Fname;
  final String uid;
  const ChatPage({super.key, required this.Fname, required this.uid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final _openAI = OpenAI.instance.build(
    token: open_AIP_Key,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
    enableLog: true);

class _ChatPageState extends State<ChatPage> {
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: "M",
    lastName: "K",
  );
  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: "Chat",
    lastName: "GPT",
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat with NutriAI",
          style: TextStyle(color: kPrimaryColor),
        ),
      ),
      body: DashChat(
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
              currentUserContainerColor: kPrimaryColor,
              containerColor: Colors.teal,
              textColor: Colors.black),
          currentUser: _currentUser,
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Map<String, dynamic>> _messageHistory =
        _messages.reversed.toList().map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text).toJson();
      } else {
        return Messages(role: Role.assistant, content: m.text).toJson();
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      maxToken: 200,
      messages: _messageHistory,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _gptChatUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
