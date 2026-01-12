import 'package:trainer_app/screens/trainer_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/service_providers.dart';
import 'package:trainer_app/screens/chat_list_screen.dart';
import 'package:trainer_app/screens/trainer_sessions_screen.dart';

class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF7F7), Color(0xFFFFE8E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.leaderboard_outlined, color: Color(0xFFE50914)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hello, Aarav', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Stay on top of members, calls, and sessions.',
                              style: TextStyle(color: Color(0xFF7A0D0D))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF7A0D0D)),
                      onPressed: () async {
                        await authService.logout();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF79009).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.schedule, color: Color(0xFFF79009)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Next up', style: TextStyle(fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4),
                                  Text('Review DK’s macros at 6pm',
                                      style: TextStyle(color: Color(0xFF7A0D0D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // Two columns for cards
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
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
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon) {
    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (title == 'Chats') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          } else if (title == 'Requests') { // New condition for Requests
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerRequestsScreen()),
            );
          } else if (title == 'Sessions') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerSessionsScreen()),
            );
          } else {
            // TODO: Implement navigation to other features
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on $title')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: const Color(0xFFE50914)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                title == 'Chats'
                    ? 'Reply fast, stay synced'
                    : title == 'Requests'
                        ? 'Approve or decline quickly'
                        : title == 'Members'
                            ? 'View your roster'
                            : 'Review history',
                style: const TextStyle(color: Color(0xFF7A0D0D), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
