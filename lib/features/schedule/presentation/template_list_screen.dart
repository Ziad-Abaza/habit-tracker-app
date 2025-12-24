import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/template_repository.dart';
import '../data/schedule_repository.dart';
import '../domain/weekly_template.dart';
import '../../../core/widgets/app_drawer.dart';

class TemplateListScreen extends ConsumerWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryAsync = ref.watch(templateRepositoryProvider);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Weekly Templates'),
      ),
      body: repositoryAsync.when(
        data: (repository) {
          return StreamBuilder<List<WeeklyTemplate>>(
            stream: repository.watchTemplates(),
            initialData: repository.getAllTemplates(),
            builder: (context, snapshot) {
              final templates = snapshot.data ?? [];
              if (templates.isEmpty) {
                return const Center(
                  child: Text('No templates yet. Create one!'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final activityCount = template.schedule.values.fold(0, (sum, list) => sum + list.length);
                  
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.go('/templates/edit/${template.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  template.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => repository.deleteTemplate(template.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.list_alt, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '$activityCount activities',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Apply'),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2030),
                                      helpText: 'Select Start of Week',
                                    );
                                    if (date != null) {
                                      final scheduleRepo = await ref.read(scheduleRepositoryProvider.future);
                                      await repository.applyTemplate(template, date, scheduleRepo);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Template applied successfully')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/templates/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
