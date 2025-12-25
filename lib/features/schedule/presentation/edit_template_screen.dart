import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/template_repository.dart';
import '../domain/weekly_template.dart';

class EditTemplateScreen extends ConsumerStatefulWidget {
  final String? templateId;

  const EditTemplateScreen({super.key, this.templateId});

  @override
  ConsumerState<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends ConsumerState<EditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Map<int, List<TemplateActivity>> _schedule = {};

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _loadTemplate();
    } else {
      for (int i = 1; i <= 7; i++) {
        _schedule[i] = [];
      }
    }
  }

  Future<void> _loadTemplate() async {
    final repository = await ref.read(templateRepositoryProvider.future);
    final templates = repository.getAllTemplates();
    final template = templates.firstWhere((t) => t.id == widget.templateId);
    _nameController.text = template.name;
    setState(() {
      _schedule = Map.from(template.schedule);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final repository = await ref.read(templateRepositoryProvider.future);
      final template = WeeklyTemplate(
        id: widget.templateId ?? const Uuid().v4(),
        name: _nameController.text,
        schedule: _schedule,
      );

      if (widget.templateId != null) {
        await repository.updateTemplate(template);
      } else {
        await repository.addTemplate(template);
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  void _addActivity(int day) async {
    final TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => const _AddActivityDialog(),
      );

      if (result != null && context.mounted) {
        setState(() {
          _schedule[day]!.add(TemplateActivity(
            title: result['title'] ?? 'New Activity',
            startHour: pickedTime.hour,
            startMinute: pickedTime.minute,
            durationMinutes: result['duration'] ?? 60,
            type: result['type'] ?? 'work',
          ));
          _schedule[day]!.sort((a, b) {
            final aTime = a.startHour * 60 + a.startMinute;
            final bTime = b.startHour * 60 + b.startMinute;
            return aTime.compareTo(bTime);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateId != null ? 'Edit Template' : 'New Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final activities = _schedule[day] ?? [];
                  return ExpansionTile(
                    title: Text(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][index]),
                    subtitle: Text('${activities.length} activities'),
                    children: [
                      ...activities.map((activity) => ListTile(
                        title: Text(activity.title),
                        subtitle: Text('${activity.startHour}:${activity.startMinute.toString().padLeft(2, '0')} - ${activity.durationMinutes} min'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _schedule[day]!.remove(activity);
                            });
                          },
                        ),
                      )),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Add Activity'),
                        onTap: () => _addActivity(day),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddActivityDialog extends StatefulWidget {
  const _AddActivityDialog();

  @override
  _AddActivityDialogState createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  String _selectedType = 'work';

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activityTypes = [
      {'value': 'work', 'label': 'Work', 'icon': Icons.work},
      {'value': 'study', 'label': 'Study', 'icon': Icons.school},
      {'value': 'exercise', 'label': 'Exercise', 'icon': Icons.fitness_center},
      {'value': 'rest', 'label': 'Rest', 'icon': Icons.hotel},
      {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
    ];

    return AlertDialog(
      title: const Text('Add Activity'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Activity Type:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: activityTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    label: Text(type['label']),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type['value'];
                      });
                    },
                    avatar: Icon(
                      type['icon'],
                      color: isSelected ? Colors.white : null,
                    ),
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                  suffixText: 'minutes',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  final minutes = int.tryParse(value);
                  if (minutes == null || minutes <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'title': _titleController.text,
                'type': _selectedType,
                'duration': int.parse(_durationController.text),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
