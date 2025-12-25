import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../domain/time_block.dart';
import '../data/schedule_repository.dart';

class ActivityDetailsScreen extends ConsumerStatefulWidget {
  final String activityId;
  final TimeOfDay? initialTime;

  const ActivityDetailsScreen({
    super.key,
    required this.activityId,
    this.initialTime,
  });

  @override
  ConsumerState<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends ConsumerState<ActivityDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _selectedType;
  late int _durationMinutes;
  DateTime? _startTime;
  TimeOfDay? _selectedTime;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Activity' : 'Activity Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveActivity,
              child: const Text('Save'),
            ),
          ],
        ],
      ),
      body: FutureBuilder<TimeBlock?>(
        future: _loadActivity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Activity not found'));
          }

          final activity = snapshot.data!;
          
          // Initialize controllers when activity loads
          if (!_isEditing) {
            _titleController.text = activity.title;
            _notesController.text = activity.notes ?? '';
            _selectedType = activity.type;
            _durationMinutes = activity.durationMinutes;
            _startTime = activity.startTime;
            _selectedTime = TimeOfDay.fromDateTime(activity.startTime);
            _categoryId = activity.categoryId;
          }

          final endTime = activity.endTime;
          final dateFormat = DateFormat('EEEE, MMMM d, y');
          final timeFormat = DateFormat('h:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing) _buildEditForm(activity) else _buildDetailView(activity, dateFormat, timeFormat, endTime),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<TimeBlock?> _loadActivity() async {
    try {
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TimeBlockAdapter());
      }
      final box = await Hive.openBox<TimeBlock>('schedule');
      return box.get(widget.activityId);
    } catch (e) {
      debugPrint('Error loading activity: $e');
      return null;
    }
  }

  Future<void> _saveActivity() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    try {
      final repository = await ref.read(scheduleRepositoryProvider.future);
      final originalActivity = await _loadActivity();
      
      if (originalActivity != null) {
        final updatedActivity = TimeBlock(
          id: originalActivity.id,
          title: _titleController.text.trim(),
          startTime: _startTime ?? originalActivity.startTime,
          durationMinutes: _durationMinutes,
          type: _selectedType,
          isCompleted: originalActivity.isCompleted,
          categoryId: _categoryId,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          color: originalActivity.color,
          icon: originalActivity.icon,
        );

        await repository.updateBlock(updatedActivity);
        
        if (mounted) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving activity: $e')),
        );
      }
    }
  }

  Widget _buildEditForm(TimeBlock activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Activity Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text('Activity Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['work', 'study', 'exercise', 'rest', 'other'].map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedType = type;
                });
              },
              avatar: Icon(
                _getActivityIcon(type),
                color: isSelected ? Colors.white : null,
              ),
              selectedColor: _getActivityColor(context, type),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
                initialValue: _durationMinutes.toString(),
                onChanged: (value) {
                  _durationMinutes = int.tryParse(value) ?? _durationMinutes;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final minutes = int.tryParse(value);
                  if (minutes == null || minutes <= 0) {
                    return 'Invalid duration';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.fromDateTime(activity.startTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                      _startTime = DateTime(
                        activity.startTime.year,
                        activity.startTime.month,
                        activity.startTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _selectedTime?.format(context) ?? TimeOfDay.fromDateTime(activity.startTime).format(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveActivity,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailView(TimeBlock activity, DateFormat dateFormat, DateFormat timeFormat, DateTime endTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          context,
          title: activity.title,
          icon: _getActivityIcon(activity.type),
          color: _getActivityColor(context, activity.type),
        ),
        const SizedBox(height: 24),
        _buildDetailRow(
          Icons.calendar_today,
          'Date',
          dateFormat.format(activity.startTime),
        ),
        const Divider(),
        _buildDetailRow(
          Icons.access_time,
          'Time',
          '${timeFormat.format(activity.startTime)} - ${timeFormat.format(endTime)}',
        ),
        const Divider(),
        _buildDetailRow(
          Icons.timer,
          'Duration',
          '${activity.durationMinutes} minutes',
        ),
        const Divider(),
        if (activity.notes?.isNotEmpty ?? false) ...[
          _buildDetailRow(
            Icons.notes,
            'Notes',
            activity.notes!,
            isMultiline: true,
          ),
          const Divider(),
        ],
        const SizedBox(height: 24),
        if (activity.isCompleted) ...[
          _buildCompletionStatus(true),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Edit Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 250,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isMultiline ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStatus(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green[100]! : Colors.orange[100]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.pending,
            color: isCompleted ? Colors.green[600] : Colors.orange[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? 'Completed' : 'Pending',
            style: TextStyle(
              color: isCompleted ? Colors.green[800] : Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      case 'exercise':
        return Icons.fitness_center;
      case 'rest':
        return Icons.hotel;
      default:
        return Icons.assignment;
    }
  }

  Color _getActivityColor(BuildContext context, String type) {
    final theme = Theme.of(context);
    switch (type) {
      case 'work':
        return Colors.blue;
      case 'study':
        return Colors.purple;
      case 'exercise':
        return Colors.green;
      case 'rest':
        return Colors.orange;
      default:
        return theme.primaryColor;
    }
  }
}
