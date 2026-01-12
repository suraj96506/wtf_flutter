import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/service_providers.dart';
import 'package:trainer_app/screens/conversation_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);
    final currentUserAsyncValue = ref.watch(currentUserStreamProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: currentUserAsyncValue.when(
        data: (user) {
          final resolvedUser = user ?? ((authService as dynamic).currentUserSync as User?);
          if (resolvedUser == null) {
            return const Center(child: Text('Not logged in'));
          }

          return StreamBuilder<List<User>>(
            stream: chatService.getConversations(resolvedUser.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final conversations = snapshot.data ?? [];
              if (conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_outlined, size: 48, color: Color(0xFFE50914)),
                      SizedBox(height: 10),
                      Text('No messages yet. Start the conversation.',
                          style: TextStyle(color: Color(0xFF7A0D0D))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversationUser = conversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: conversationUser.avatarUrl != null
                          ? NetworkImage(conversationUser.avatarUrl!)
                          : null,
                      backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.12),
                      child: conversationUser.avatarUrl == null
                          ? const Icon(Icons.person, color: Color(0xFFE50914))
                          : null,
                    ),
                    title: Text(conversationUser.name),
                    subtitle: const Text('Last message preview...'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('5m ago', style: TextStyle(color: Color(0xFFE50914))),
                        ),
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: const Color(0xFFE50914),
                          child: const Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(otherUser: conversationUser),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start a new chat...')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
