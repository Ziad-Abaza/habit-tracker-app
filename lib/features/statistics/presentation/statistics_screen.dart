import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'statistics_controller.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../habits/domain/habit.dart';
import '../../settings/presentation/settings_controller.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Statistics & Analytics'),
        elevation: 0,
      ),
      body: statsAsync.when(
        data: (stats) {
          final habits = stats['habits'] as List<Habit>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context, stats),
                const SizedBox(height: 24),
                _buildProgressTracker(context, stats),
                const SizedBox(height: 24),
                _buildHabitPerformance(context, habits),
                const SizedBox(height: 24),
                _buildDailyReminderCard(context, ref),
                const SizedBox(height: 80), // Space for bottom
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildStatCard(
          context,
          'Total Habits',
          stats['totalHabits'].toString(),
          Icons.list_alt,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          'Current Streak',
          '${stats['activeStreaks']} days',
          Icons.local_fire_department,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          'Best Streak',
          '${stats['bestStreak']} days',
          Icons.emoji_events,
          Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          'Completion Rate',
          '${(stats['overallCompletionRate'] * 100).toStringAsFixed(1)}%',
          Icons.pie_chart,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker(BuildContext context, Map<String, dynamic> stats) {
    final weeklyProgress = stats['weeklyProgress'] as List<double>;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress Tracker',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat.E().format(date).substring(0, 1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyProgress[i],
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 1.0,
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitPerformance(BuildContext context, List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Performance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...habits.take(5).map((habit) {
          final completionRate = habit.completedDates.length / 30; // Last 30 days approx
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(habit.title),
              subtitle: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRate.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  minHeight: 8,
                ),
              ),
              trailing: Text(
                '${habit.completedDates.length} total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDailyReminderCard(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      children: [
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            leading: Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            title: const Text(
              'End-of-day Reminder',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(settings.endOfDayReminder 
              ? 'Scheduled for ${settings.endOfDayReminderTime.format(context)}'
              : 'Review your activities and log progress'),
            trailing: Switch(
              value: settings.endOfDayReminder,
              onChanged: (value) => controller.toggleEndOfDayReminder(value),
            ),
            children: [
              if (settings.endOfDayReminder)
                ListTile(
                  title: const Text('Reminder Time'),
                  trailing: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.endOfDayReminderTime,
                      );
                      if (time != null) {
                        controller.setEndOfDayReminderTime(time);
                      }
                    },
                    child: Text(settings.endOfDayReminderTime.format(context)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
