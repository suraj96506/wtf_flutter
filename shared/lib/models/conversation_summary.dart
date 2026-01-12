import 'package:shared/models/user.dart';

class ConversationSummary {
  final String chatId;
  final User otherUser;
  final String lastMessage;
  final DateTime lastTime;
  final int unread;

  ConversationSummary({
    required this.chatId,
    required this.otherUser,
    required this.lastMessage,
    required this.lastTime,
    required this.unread,
  });
}
