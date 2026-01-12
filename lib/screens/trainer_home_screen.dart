import 'package:trainer_app/screens/trainer_requests_screen.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/service_providers.dart';
import 'package:trainer_app/screens/chat_list_screen.dart';

class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Placeholder for Trainer Info or Welcome Message
            const Text(
              'Welcome, Trainer!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 4 Tiles: Members, Chats, Requests, Sessions
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns for cards
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildFeatureCard(context, 'Members', Icons.people),
                  _buildFeatureCard(context, 'Chats', Icons.message),
                  _buildFeatureCard(context, 'Requests', Icons.pending_actions),
                  _buildFeatureCard(context, 'Sessions', Icons.history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (title == 'Chats') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          } else if (title == 'Requests') { // New condition for Requests
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerRequestsScreen()),
            );
          } else {
            // TODO: Implement navigation to other features
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on $title')),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}