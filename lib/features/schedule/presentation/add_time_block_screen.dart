import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/schedule_repository.dart';
import '../domain/time_block.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import '../../../core/notifications/notification_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddTimeBlockScreen extends ConsumerStatefulWidget {
  final String? blockId;
  const AddTimeBlockScreen({super.key, this.blockId});

  @override
  ConsumerState<AddTimeBlockScreen> createState() => _AddTimeBlockScreenState();
}

class _AddTimeBlockScreenState extends ConsumerState<AddTimeBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 60;
  String _selectedType = 'work';
  String? _selectedCategoryId;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.event;

  final List<String> _types = ['work', 'study', 'exercise', 'rest', 'other'];

  @override
  void initState() {
    super.initState();
    if (widget.blockId != null) {
      _loadBlock();
    }
  }

  Future<void> _loadBlock() async {
    final repository = await ref.read(scheduleRepositoryProvider.future);
    final block = repository.getBlock(widget.blockId!);
    
    if (block != null) {
      setState(() {
        _titleController.text = block.title;
        _notesController.text = block.notes ?? '';
        _selectedDate = block.startTime;
        _selectedTime = TimeOfDay(hour: block.startTime.hour, minute: block.startTime.minute);
        _durationMinutes = block.durationMinutes;
        _selectedType = block.type;
        _selectedCategoryId = block.categoryId;
        if (block.color != null) _selectedColor = Color(block.color!);
        if (block.icon != null) _selectedIcon = IconData(block.icon!, fontFamily: 'MaterialIcons');
      });
    }
  }

  Future<void> _saveBlock() async {
    if (_formKey.currentState!.validate()) {
      final repository = await ref.read(scheduleRepositoryProvider.future);
      
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final block = TimeBlock(
        id: widget.blockId ?? const Uuid().v4(),
        title: _titleController.text,
        startTime: startTime,
        durationMinutes: _durationMinutes,
        type: _selectedType,
        categoryId: _selectedCategoryId,
        notes: _notesController.text,
        color: _selectedColor.value,
        icon: _selectedIcon.codePoint,
      );

      if (repository.checkForConflicts(block)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conflict detected! This activity overlaps with another.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (widget.blockId != null) {
        await repository.updateBlock(block);
      } else {
        await repository.addBlock(block);
      }

      // Schedule notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleNotification(
        id: block.id.hashCode,
        title: 'Activity Starting: ${block.title}',
        body: 'Your activity "${block.title}" is starting now.',
        scheduledDate: startTime,
      );

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockId != null ? 'Edit Activity' : 'Add Activity'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
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
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _durationMinutes.toString(),
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _durationMinutes = int.tryParse(value) ?? 60;
                });
              },
            ),
            const SizedBox(height: 16),
            // Category Selection
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoryRepositoryProvider);
                return categoriesAsync.when(
                  data: (repository) {
                    return StreamBuilder<List<Category>>(
                      stream: repository.watchCategories(),
                      initialData: repository.getAllCategories(),
                      builder: (context, snapshot) {
                        final categories = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Row(
                                children: [
                                  Icon(IconData(category.icon, fontFamily: 'MaterialIcons'), 
                                       color: Color(category.color), size: 20),
                                  const SizedBox(width: 8),
                                  Text(category.name),
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
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading categories: $error'),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Color'),
              trailing: CircleAvatar(backgroundColor: _selectedColor),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: _selectedColor,
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveBlock,
              child: const Text('Add Activity'),
            ),
          ],
        ),
      ),
    );
  }
}
