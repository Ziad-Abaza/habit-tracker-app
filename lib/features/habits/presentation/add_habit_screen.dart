import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../domain/habit.dart';
import '../data/habit_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import 'package:intl/intl.dart';
import '../../../core/notifications/notification_service.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  final String? habitId;
  const AddHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<int> _selectedDays = [];
  TimeOfDay? _selectedTime;
  int _durationMinutes = 0;
  String? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabit();
    }
  }

  Future<void> _loadHabit() async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final habits = repository.getAllHabits();
    final habit = habits.firstWhere((h) => h.id == widget.habitId);

    setState(() {
      _titleController.text = habit.title;
      _descriptionController.text = habit.description;
      _selectedDays = List.from(habit.frequency);
      if (habit.time != null) {
        _selectedTime = TimeOfDay(hour: habit.time!.hour, minute: habit.time!.minute);
      }
      _durationMinutes = habit.durationMinutes;
      _selectedCategoryId = habit.categoryId;
      _startDate = habit.startDate;
      _endDate = habit.endDate;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
      _selectedDays.sort();
    });
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      final repository = await ref.read(habitRepositoryProvider.future);
      final habit = Habit(
        id: widget.habitId ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        frequency: _selectedDays,
        time: _selectedTime != null
            ? DateTime(0, 0, 0, _selectedTime!.hour, _selectedTime!.minute)
            : null,
        durationMinutes: _durationMinutes,
        categoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (widget.habitId != null) {
        await repository.updateHabit(habit);
      } else {
        await repository.addHabit(habit);
      }
      
      // Schedule notifications if time is set
      if (habit.time != null) {
        final notificationService = ref.read(notificationServiceProvider);
        
        // Schedule notifications for each day in the frequency
        for (int dayOfWeek in habit.frequency) {
          // Find the next occurrence of this day
          final now = DateTime.now();
          int daysUntilNext = (dayOfWeek - now.weekday) % 7;
          
          // If it's 0, it means today - check if time has passed
          if (daysUntilNext == 0) {
            final scheduledTime = DateTime(
              now.year,
              now.month,
              now.day,
              habit.time!.hour,
              habit.time!.minute,
            );
            
            // If time has passed today, schedule for next week
            if (now.isAfter(scheduledTime)) {
              daysUntilNext = 7;
            }
          }
          
          final nextOccurrence = DateTime(
            now.year,
            now.month,
            now.day + daysUntilNext,
            habit.time!.hour,
            habit.time!.minute,
          );
          
          print('Scheduling habit notification for: $nextOccurrence (Day: $dayOfWeek)');
          
          // Only schedule if within start/end date range
          if ((habit.startDate == null || !nextOccurrence.isBefore(habit.startDate!)) &&
              (habit.endDate == null || !nextOccurrence.isAfter(habit.endDate!))) {
            await notificationService.scheduleNotification(
              id: habit.id.hashCode + dayOfWeek,
              title: 'Habit Reminder: ${habit.title}',
              body: habit.description.isNotEmpty ? habit.description : 'Time to complete your habit!',
              scheduledDate: nextOccurrence,
            );
          }
        }
      }
      
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId != null ? 'Edit Habit' : 'New Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                  selected: isSelected,
                  onSelected: (_) => _toggleDay(day),
                );
              }),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(_selectedTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveHabit,
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
