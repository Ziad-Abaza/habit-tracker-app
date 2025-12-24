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
    // TODO: Show dialog to add activity
    // For now, adding a dummy activity
    setState(() {
      _schedule[day]!.add(TemplateActivity(
        title: 'New Activity',
        startHour: 9,
        startMinute: 0,
        durationMinutes: 60,
        type: 'work',
      ));
    });
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
