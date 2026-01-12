import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/services/service_providers.dart';
import 'package:shared/models/user.dart'; // Import User model

class ScheduleCallScreen extends ConsumerStatefulWidget {
  const ScheduleCallScreen({super.key});

  @override
  ConsumerState<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends ConsumerState<ScheduleCallScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule a Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTimeSlotSelector(),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: 140,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _selectedTime == null ? null : _requestCall,
                child: const Text('Request Call'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a day:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
            return ChoiceChip(
              label: Text('${date.day}/${date.month}'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null; // Reset time when date changes
                  });
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    // Generate 30-minute time slots from 9 AM to 5 PM
    final timeSlots = List.generate(16, (index) {
      final hour = 9 + (index ~/ 2);
      final minute = (index % 2) * 30;
      return TimeOfDay(hour: hour, minute: minute);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a time:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: timeSlots.map((time) {
            final isSelected = _selectedTime == time;
            final now = DateTime.now();
            final selectedDateTime = DateTime(
                _selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute);
            final bool isPast = selectedDateTime.isBefore(now);

            // TODO: Add conflict check logic here

            return ChoiceChip(
              label: Text(time.format(context)),
              selected: isSelected,
              onSelected: isPast ? null : (selected) {
                if (selected) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _requestCall() async {
    if (_selectedTime == null) {
      return;
    }

    final callService = ref.read(callServiceProvider);
    final currentUser = ref.read(currentUserStreamProvider).value;

    if (currentUser == null || currentUser.role != 'member') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only members can request calls.')),
      );
      return;
    }

    // Ensure Aarav is the assigned trainer for DK
    final trainer = User(
      id: 'aarav_trainer_id',
      role: 'trainer',
      name: 'Aarav (Lead Trainer)',
      email: 'aarav@example.com',
    );

    final scheduledFor = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final newCallRequest = CallRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      memberId: currentUser.id,
      trainerId: trainer.id,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: _noteController.text,
      status: CallRequestStatus.pending,
    );

    await callService.requestCall(newCallRequest);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call requested. Pending approval by Aarav.')),
    );

    Navigator.of(context).pop(); // Go back to home screen
  }
}
