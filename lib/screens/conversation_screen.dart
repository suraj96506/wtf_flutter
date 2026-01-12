import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/models/message.dart';
import 'package:shared/services/chat_service.dart';
import 'package:shared/services/service_providers.dart';
import 'package:shared/services/http_chat_service.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final User otherUser;

  const ConversationScreen({super.key, required this.otherUser});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);
    final currentUser = ref.watch(currentUserStreamProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    final chatId = _getChatId(currentUser.id, widget.otherUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatService.getMessages(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];

                // Mark incoming messages as read when this screen is open
                final toMark = messages
                    .where((m) => m.receiverId == currentUser.id && m.status != MessageStatus.read)
                    .map((m) => m.id)
                    .toList();
                if (toMark.isNotEmpty) {
                  chatService.markMessagesAsRead(chatId, toMark);
                }

                // Scroll to bottom on new message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.id;
                    return _buildMessageBubble(context, message, isMe);
                  },
                );
              },
            ),
          ),
          // Typing indicator
          StreamBuilder<bool>(
            stream: chatService is HttpChatService
                ? chatService.getTypingStatusFor(chatId, currentUser.id)
                : chatService.getTypingStatus(chatId),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text('Typing...'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Quick replies
          _buildQuickReplies(chatService, chatId, currentUser),
          // Message input
          _buildMessageInput(chatService, chatId, currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message, bool isMe) {
    const trainerRed = Color(0xFFE50914);
    const memberBlue = Color(0xFF1A73E8); // fresher blue for member side
    final bubbleColor = isMe ? trainerRed.withValues(alpha: 0.12) : memberBlue.withValues(alpha: 0.12);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Icon _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 12, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue); // Still blue, can be customized
    }
  }

  Widget _buildQuickReplies(ChatService chatService, String chatId, User currentUser) {
    final quickReplies = ["Got it 👍", "Can we talk at 6?", "Share plan?"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: quickReplies.map((reply) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ActionChip(
                label: Text(reply),
                onPressed: () {
                  final message = Message(
                    id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                    chatId: chatId,
                    senderId: currentUser.id,
                    receiverId: widget.otherUser.id,
                    text: reply,
                    createdAt: DateTime.now(),
                    status: MessageStatus.sending,
                  );
                  chatService.sendMessage(message);
                  chatService.simulateTyping(chatId, true, userId: currentUser.id);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    chatService.simulateTyping(chatId, false, userId: currentUser.id);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatService chatService, String chatId, User currentUser) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (text) {
                // Simulate typing
                chatService.simulateTyping(chatId, text.isNotEmpty, userId: currentUser.id);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                final message = Message(
                  id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                  chatId: chatId,
                  senderId: currentUser.id,
                  receiverId: widget.otherUser.id,
                  text: _textController.text,
                  createdAt: DateTime.now(),
                  status: MessageStatus.sending,
                );
                chatService.sendMessage(message);
                chatService.simulateTyping(chatId, true, userId: currentUser.id);
                Future.delayed(const Duration(milliseconds: 500), () {
                  chatService.simulateTyping(chatId, false, userId: currentUser.id);
                });
                _textController.clear();
                chatService.simulateTyping(chatId, false, userId: currentUser.id);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getChatId(String user1Id, String user2Id) {
    return (user1Id.compareTo(user2Id) < 0)
        ? '${user1Id}_$user2Id'
        : '${user2Id}_$user1Id';
  }
}

