import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../habits/data/habit_repository.dart';
import '../../habits/domain/habit.dart';

part 'statistics_controller.g.dart';

@riverpod
class StatisticsController extends _$StatisticsController {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    final repository = await ref.watch(habitRepositoryProvider.future);
    
    // We watch the habits stream to rebuild when habits change
    return ref.watch(StreamProvider((ref) => repository.watchHabits())).when(
      data: (habits) => _calculateStats(habits),
      loading: () => _emptyStats(),
      error: (_, __) => _emptyStats(),
    );
  }

  Map<String, dynamic> _emptyStats() {
    return {
      'totalHabits': 0,
      'overallCompletionRate': 0.0,
      'activeStreaks': 0,
      'bestStreak': 0,
      'weeklyProgress': <double>[0, 0, 0, 0, 0, 0, 0],
      'habits': <Habit>[],
    };
  }

  Map<String, dynamic> _calculateStats(List<Habit> habits) {
    if (habits.isEmpty) return _emptyStats();

    int totalCompletions = 0;
    int totalOpportunities = 0;
    int currentStreaksSum = 0;
    int maxStreak = 0;

    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    });

    final weeklyProgress = List.generate(7, (index) => 0.0);
    final weeklyCompletions = List.generate(7, (index) => 0);
    final weeklyTotal = List.generate(7, (index) => 0);

    for (final habit in habits) {
      totalCompletions += habit.completedDates.length;
      
      if (habit.startDate != null) {
        final daysSinceStart = now.difference(habit.startDate!).inDays + 1;
        totalOpportunities += daysSinceStart > 0 ? daysSinceStart : 1; 
      } else {
        // Estimate based on first completion or just 30 days
        if (habit.completedDates.isNotEmpty) {
          final firstDate = habit.completedDates.reduce((a, b) => a.isBefore(b) ? a : b);
          totalOpportunities += now.difference(firstDate).inDays + 1;
        } else {
          totalOpportunities += 1;
        }
      }

      final streak = _calculateStreak(habit);
      if (streak > 0) currentStreaksSum += streak;
      if (streak > maxStreak) maxStreak = streak;

      for (int i = 0; i < 7; i++) {
        final date = last7Days[i];
        if (_isHabitScheduledOn(habit, date)) {
          weeklyTotal[i]++;
          if (habit.isCompletedOnDate(date)) {
            weeklyCompletions[i]++;
          }
        }
      }
    }

    for (int i = 0; i < 7; i++) {
      if (weeklyTotal[i] > 0) {
        weeklyProgress[i] = weeklyCompletions[i] / weeklyTotal[i];
      }
    }

    return {
      'totalHabits': habits.length,
      'overallCompletionRate': totalOpportunities > 0 ? totalCompletions / totalOpportunities : 0.0,
      'activeStreaks': currentStreaksSum,
      'bestStreak': maxStreak,
      'weeklyProgress': weeklyProgress,
      'habits': habits,
    };
  }

  int _calculateStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    
    final sortedDates = List<DateTime>.from(habit.completedDates)
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime checkDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    bool completedToday = habit.isCompletedOnDate(checkDate);
    bool completedYesterday = habit.isCompletedOnDate(checkDate.subtract(const Duration(days: 1)));
    
    if (!completedToday && !completedYesterday) return 0;
    
    if (!completedToday) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.isCompletedOnDate(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (!_isHabitScheduledOn(habit, checkDate)) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          if (streak > 1000) break; // Infinite loop protection
          continue;
        }
        break;
      }
      if (streak > 3650) break; 
    }
    
    return streak;
  }

  bool _isHabitScheduledOn(Habit habit, DateTime date) {
    if (habit.frequency.isEmpty) return true;
    return habit.frequency.contains(date.weekday);
  }
}
