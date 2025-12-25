import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../settings/presentation/settings_controller.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HabitListScreen extends ConsumerWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryAsync = ref.watch(habitRepositoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(settings.showAllDays ? 'All Habits' : 'Habits'),
        actions: [
          if (!settings.showAllDays)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  ref.read(selectedDateProvider.notifier).state = date;
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.calendar_view_week),
            onPressed: () => context.go('/templates'),
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () => context.go('/schedule'),
          ),
        ],
        bottom: settings.showAllDays ? null : PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
                final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
                
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = date;
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: repositoryAsync.when(
        data: (repository) {
          return StreamBuilder<List<Habit>>(
            stream: repository.watchHabits(),
            initialData: repository.getAllHabits(),
            builder: (context, snapshot) {
              final allHabits = snapshot.data ?? [];
              final habits = settings.showAllDays 
                  ? allHabits 
                  : repository.getHabitsForDate(selectedDate);
              
              if (habits.isEmpty) {
                return Center(
                  child: Text(settings.showAllDays 
                      ? 'No habits created yet.' 
                      : 'No habits for this day.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final isCompact = settings.compactView;
                  
                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isCompact ? 2 : 6,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.push('/edit-habit/${habit.id}');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isCompact ? 4 : 8,
                        ),
                        child: Row(
                          children: [
                            if (!settings.showAllDays)
                              Transform.scale(
                                scale: isCompact ? 1.0 : 1.2,
                                child: Checkbox(
                                  value: habit.isCompletedOnDate(selectedDate),
                                  shape: const CircleBorder(),
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (value) {
                                    if (settings.hapticFeedback) {
                                      HapticFeedback.mediumImpact();
                                    }
                                    repository.toggleCompletion(habit.id, selectedDate);
                                  },
                                ),
                              )
                            else 
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                                child: Icon(Icons.repeat, color: Theme.of(context).colorScheme.primary, size: 20),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isCompact ? 14 : 16,
                                      decoration: !settings.showAllDays && habit.isCompletedOnDate(selectedDate)
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: !settings.showAllDays && habit.isCompletedOnDate(selectedDate)
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                  if (!isCompact && habit.description.isNotEmpty)
                                    Text(
                                      habit.description,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                                size: isCompact ? 20 : 24,
                              ),
                              onPressed: () => repository.deleteHabit(habit.id),
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
        onPressed: () => context.go('/add-habit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
