import 'package:shared/models/message.dart';
import 'package:shared/models/user.dart';

abstract class ChatService {
  Future<void> sendMessage(Message message);
  Stream<List<Message>> getMessages(String chatId);
  Stream<bool> getTypingStatus(String chatId); // Indicate if other user is typing
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds);
  Stream<List<User>> getConversations(String currentUserId); // List of users with whom current user has chatted
  Future<void> simulateTyping(String chatId, bool isTyping, {String? userId}); // For mock service to simulate
  void dispose();
}
