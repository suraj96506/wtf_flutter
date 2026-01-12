import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/services/firestore_call_service.dart';
import 'package:shared/services/service_providers.dart';

class TrainerSessionsScreen extends ConsumerStatefulWidget {
  const TrainerSessionsScreen({super.key});

  @override
  ConsumerState<TrainerSessionsScreen> createState() => _TrainerSessionsScreenState();
}

class _TrainerSessionsScreenState extends ConsumerState<TrainerSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callService = ref.watch(callServiceProvider);
    final currentUser = ref.watch(currentUserStreamProvider).value;

    if (currentUser == null || currentUser.role != 'trainer') {
      return const Scaffold(body: Center(child: Text('Not authorized')));
    }

    final requestsStream = callService is FirestoreCallService
        ? callService.getCallRequestsForTrainer(currentUser.id)
        : callService.getCallRequests(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scheduled'),
            Tab(text: 'Video Calls'),
          ],
        ),
      ),
      body: StreamBuilder<List<CallRequest>>(
        stream: requestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final approved = (snapshot.data ?? [])
              .where((req) => req.status == CallRequestStatus.approved)
              .toList();

          if (approved.isEmpty) {
            return const _EmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _SessionsList(requests: approved),
              _SessionsList(requests: approved), // reuse for video call tab
            ],
          );
        },
      ),
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({required this.requests});
  final List<CallRequest> requests;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requests[index];
        final when = DateFormat('EEE, MMM d • h:mm a').format(req.scheduledFor.toLocal());
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE50914).withOpacity(0.12),
                      child: const Icon(Icons.person, color: Color(0xFFE50914)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.memberName.isNotEmpty ? req.memberName : req.memberId,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            when,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B76A).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF12B76A).withOpacity(0.5)),
                      ),
                      child: const Text(
                        'APPROVED',
                        style: TextStyle(
                          color: Color(0xFF12B76A),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (req.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_rounded, size: 16, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req.note,
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_available, size: 64, color: Color(0xFFE50914)),
            SizedBox(height: 12),
            Text(
              'No approved sessions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 6),
            Text(
              'Approve a request to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
