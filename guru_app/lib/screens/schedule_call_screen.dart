import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/services/service_providers.dart';
import 'package:shared/models/user.dart';

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
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6F8FC), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCard(),
                const SizedBox(height: 20),
                _buildDateSelector(),
                const SizedBox(height: 20),
                _buildTimeSlotSelector(),
                const SizedBox(height: 20),
                _noteField(),
                const SizedBox(height: 24),
                _primaryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1769E0), Color(0xFF0F4EA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Plan your next session',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pick a slot, add a note, and send to your trainer.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
            final label = DateFormat('d MMM').format(date);
            return _pillButton(
              label: label,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                });
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
        const Text('Select a time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
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

            return _pillButton(
              label: time.format(context),
              selected: isSelected,
              enabled: !isPast,
              onTap: () {
                setState(() {
                  _selectedTime = time;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add a note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'Ex: Macros review, form check...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          maxLines: 3,
          maxLength: 140,
        ),
      ],
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedTime == null ? null : _requestCall,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFF1769E0),
          foregroundColor: Colors.white,
        ),
        child: const Text('Request Call'),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required bool selected,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1769E0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1769E0) : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1769E0).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
      trainerName: trainer.name,
      memberName: currentUser.name,
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
