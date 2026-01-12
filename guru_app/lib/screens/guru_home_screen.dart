import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guru_app/screens/schedule_call_screen.dart';
import 'package:shared/services/service_providers.dart';
import 'package:guru_app/screens/chat_list_screen.dart';
import 'package:guru_app/screens/my_sessions_screen.dart';

class GuruHomeScreen extends ConsumerWidget {
  const GuruHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F8FC), Color(0xFFEAF1FF)],
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
                        color: const Color(0xFF1769E0).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.self_improvement, color: Color(0xFF1769E0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Welcome back, DK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Stay consistent. Your trainer is a tap away.',
                              style: TextStyle(color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF0F1F3C)),
                      onPressed: () async {
                        await authService.logout();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                        color: const Color(0xFF12B76A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                              child: const Icon(Icons.bolt, color: Color(0xFF12B76A)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Today’s focus', style: TextStyle(fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4),
                                  Text('Macro check-in with Aarav at 6pm',
                                      style: TextStyle(color: Color(0xFF6B7280))),
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
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    children: [
                      _buildFeatureCard(context, 'Chat with Trainer', Icons.chat_bubble_outline),
                      _buildFeatureCard(context, 'Schedule Call', Icons.calendar_today),
                      _buildFeatureCard(context, 'My Sessions', Icons.history_toggle_off),
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
          if (title == 'Chat with Trainer') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          } else if (title == 'Schedule Call') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScheduleCallScreen()),
            );
          } else if (title == 'My Sessions') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MySessionsScreen()),
            );
          } else {
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
                  color: const Color(0xFF1769E0).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF1769E0)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                title == 'Chat with Trainer'
                    ? 'Ask, share, align'
                    : title == 'Schedule Call'
                        ? 'Book a slot fast'
                        : 'Track your past',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
