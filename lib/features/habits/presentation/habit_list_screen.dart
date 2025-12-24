import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../../../core/widgets/app_drawer.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HabitListScreen extends ConsumerWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryAsync = ref.watch(habitRepositoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
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
        bottom: PreferredSize(
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
              // Filter habits for selected date
              final habits = repository.getHabitsForDate(selectedDate);
              
              if (habits.isEmpty) {
                return const Center(
                  child: Text('No habits for this day.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.push('/edit-habit/${habit.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: habit.isCompletedOnDate(selectedDate),
                                shape: const CircleBorder(),
                                activeColor: Theme.of(context).colorScheme.primary,
                                onChanged: (value) {
                                  repository.toggleCompletion(habit.id, selectedDate);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: habit.isCompletedOnDate(selectedDate)
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: habit.isCompletedOnDate(selectedDate)
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                  if (habit.description.isNotEmpty)
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
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
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
