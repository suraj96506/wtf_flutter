import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/services/firestore_call_service.dart';
import 'package:shared/services/service_providers.dart';

class TrainerRequestsScreen extends ConsumerWidget {
  const TrainerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callService = ref.watch(callServiceProvider);
    final currentUser = ref.watch(currentUserStreamProvider).value;

    if (currentUser == null || currentUser.role != 'trainer') {
      return Scaffold(
        appBar: AppBar(title: const Text('Requests')),
        body: const Center(
          child: Text('You must be a trainer to view requests.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Call Requests')),
      body: StreamBuilder<List<CallRequest>>(
        stream: callService is FirestoreCallService
            ? callService.getCallRequestsForTrainer(currentUser.id)
            : callService.getCallRequests(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingRequests = (snapshot.data ?? [])
              .where((req) => req.status == CallRequestStatus.pending)
              .toList();

          if (pendingRequests.isEmpty) {
            return const Center(child: Text('No pending call requests yet.'));
          }

          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member: ${request.memberName.isNotEmpty ? request.memberName : request.memberId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'When: ${DateFormat('EEE, MMM d, yyyy - h:mm a').format(request.scheduledFor)}',
                      ),
                      if (request.note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Note: ${request.note}'),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await callService.approveCall(request);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call request approved!'),
                                ),
                              );
                            },
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () async {
                              await callService.declineCall(request);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call request declined.'),
                                ),
                              );
                            },
                            child: const Text('Decline'),
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
      ),
    );
  }
}
