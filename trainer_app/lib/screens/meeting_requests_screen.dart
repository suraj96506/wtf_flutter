import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/service_providers.dart';
import 'package:shared/services/meeting_service.dart';
import 'package:intl/intl.dart';

class MeetingRequestsScreen extends ConsumerWidget {
  const MeetingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final meetingService = ref.read(meetingServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Requests'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: authService.currentUser.first,
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = userSnapshot.data;
          if (currentUser == null || currentUser.role != 'trainer') {
            return const Center(
              child: Text('Only trainers can view meeting requests'),
            );
          }

          return StreamBuilder(
            stream: meetingService.getTrainerMeetingRequests(currentUser.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No meeting requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A0D0D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check back later for new requests',
                        style: TextStyle(color: Color(0xFF7A0D0D)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Member info
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE50914).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFFE50914),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.memberName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request.topic,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7A0D0D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Meeting details
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFFE50914)),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a')
                                    .format(request.scheduledFor),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7A0D0D),
                                ),
                              ),
                            ],
                          ),
                          if (request.description != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              request.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A0D0D),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  await meetingService.declineMeetingRequest(request.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request declined')),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE50914)),
                                ),
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await meetingService.approveMeetingRequest(request.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Meeting confirmed!')),
                                    );
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
