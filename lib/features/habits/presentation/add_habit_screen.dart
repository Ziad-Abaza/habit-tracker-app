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
import '../../../core/utils/icon_helper.dart';

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
  List<DateTime> _reminders = [];
  String _priority = 'Medium';

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
      _reminders = habit.reminders ?? [];
      _priority = habit.priority;
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
        reminders: _reminders,
        priority: _priority,
      );

      if (widget.habitId != null) {
        await repository.updateHabit(habit);
      } else {
        await repository.addHabit(habit);
      }
      
      // Schedule notifications
      final notificationService = ref.read(notificationServiceProvider);
      
      // Cancel existing ones first if editing
      if (widget.habitId != null) {
        for (int i = 0; i < 7; i++) {
          await notificationService.cancelNotification(habit.id.hashCode + i);
          for (int r = 0; r < 5; r++) { // Assuming max 5 custom reminders
             await notificationService.cancelNotification(habit.id.hashCode + 100 + (i * 10) + r);
          }
        }
      }

      Future<void> scheduleAt(DateTime targetTime, int offset) async {
        for (int dayOfWeek in habit.frequency) {
          final now = DateTime.now();
          int daysUntilNext = (dayOfWeek - now.weekday) % 7;
          
          if (daysUntilNext == 0) {
            final scheduledTime = DateTime(
              now.year,
              now.month,
              now.day,
              targetTime.hour,
              targetTime.minute,
            );
            if (now.isAfter(scheduledTime)) {
              daysUntilNext = 7;
            }
          }
          
          final nextOccurrence = DateTime(
            now.year,
            now.month,
            now.day + daysUntilNext,
            targetTime.hour,
            targetTime.minute,
          );
          
          if ((habit.startDate == null || !nextOccurrence.isBefore(habit.startDate!)) &&
              (habit.endDate == null || !nextOccurrence.isAfter(habit.endDate!))) {
            await notificationService.scheduleNotification(
              id: habit.id.hashCode + offset + dayOfWeek,
              title: 'Habit Reminder: ${habit.title}',
              body: habit.description.isNotEmpty ? habit.description : 'Time to complete your habit!',
              scheduledDate: nextOccurrence,
            );
          }
        }
      }

      // Schedule primary time
      if (habit.time != null) {
        await scheduleAt(habit.time!, 0);
      }

      // Schedule additional reminders
      if (habit.reminders != null) {
        for (int i = 0; i < habit.reminders!.length; i++) {
          await scheduleAt(habit.reminders![i], 100 + (i * 10));
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
                prefixIcon: Icon(Icons.edit),
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
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
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
              contentPadding: EdgeInsets.zero,
              title: const Text('Primary Reminder Time', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_selectedTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Habit Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Category Selection
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoryRepositoryProvider);
                return categoriesAsync.when(
                  data: (repository) {
                    final categories = repository.getAllCategories();
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Row(
                            children: [
                              Icon(IconHelper.getIconData(cat.icon), color: Color(cat.color)),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading categories'),
                );
              },
            ),
            const SizedBox(height: 16),

            // Priority Selection
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: ['Low', 'Medium', 'High'].map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Date Range
            const Text('Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate != null ? DateFormat('MMM d, yyyy').format(_startDate!) : 'Not set'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'No limit'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 30)),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reminders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_alarm),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        final now = DateTime.now();
                        _reminders.add(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                        _reminders.sort();
                      });
                    }
                  },
                ),
              ],
            ),
            if (_reminders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No custom reminders set', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              )
            else
              Wrap(
                spacing: 8,
                children: _reminders.map((reminder) {
                  return Chip(
                    label: Text(DateFormat('hh:mm a').format(reminder)),
                    onDeleted: () {
                      setState(() {
                        _reminders.remove(reminder);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(widget.habitId != null ? 'Update Habit' : 'Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
