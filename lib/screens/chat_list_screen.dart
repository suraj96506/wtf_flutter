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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: currentUserAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return StreamBuilder<List<User>>(
            stream: chatService.getConversations(user.id),
            builder: (context, conversationSnapshot) {
              if (conversationSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (conversationSnapshot.hasError) {
                return Center(child: Text('Error: ${conversationSnapshot.error}'));
              }
              final conversations = conversationSnapshot.data ?? [];
              if (conversations.isEmpty) {
                return const Center(
                  child: Text('No conversations yet.'),
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
                      child: conversationUser.avatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(conversationUser.name),
                    subtitle: const Text('Last message preview...'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('5m ago'),
                        const SizedBox(height: 4),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Theme.of(context).primaryColor,
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
        error: (error, stack) => Center(child: Text('Error: $error')),
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
