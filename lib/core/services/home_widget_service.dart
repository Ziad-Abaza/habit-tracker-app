import 'package:home_widget/home_widget.dart';
import '../../features/habits/domain/habit.dart';

class HomeWidgetService {
  static const String _groupId = 'group.com.example.habit'; // For iOS App Groups
  static const String _androidWidgetName = 'HabitWidgetProvider';

  static Future<void> updateWidget(List<Habit> habits) async {
    final habitsSummary = habits.isEmpty
        ? 'No habits for today'
        : habits.map((h) => '${h.isCompletedToday ? "✅" : "⭕"} ${h.title}').join('\n');

    await HomeWidget.setAppGroupId(_groupId);
    await HomeWidget.saveWidgetData<String>('widget_title', "Today's Habits");

    await HomeWidget.saveWidgetData<String>('widget_content', habitsSummary);

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: 'HabitWidget', // This should match the Widget's name in iOS
    );
  }
}
