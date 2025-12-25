import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../settings/presentation/settings_controller.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGuideSection(
            context,
            title: 'Habit Tracking',
            icon: Icons.check_circle_outline,
            color: Colors.indigo,
            description: 'The home screen shows your active habits. Tap a habit to mark it as completed for the day. Long press to edit or delete.',
            details: [
              '• Create a new habit using the FAB (+) button.',
              '• Set frequency (daily, weekly, etc.).',
              '• Track your current and best streaks.',
              '• View categories to group your habits.',
            ],
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            title: 'Daily Schedule',
            icon: Icons.schedule,
            color: Colors.teal,
            description: 'Manage your time efficiently using the Timeline view. Block out segments of your day for specific activities.',
            details: [
              '• Add time blocks for specific activities.',
              '• Use "Templates" to quickly apply a full day routine.',
              '• Get notified when it\'s time to start a new activity.',
            ],
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            title: 'Templates',
            icon: Icons.calendar_view_week,
            color: Colors.amber[800]!,
            description: 'Templates are pre-defined routines. You can create a "Work Day" or "Weekend" template and apply it to any day.',
            details: [
              '• Create a template with all your activities.',
              '• Apply the template to today or future dates.',
              '• Perfect for maintaining a consistent routine.',
            ],
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            title: 'Statistics',
            icon: Icons.bar_chart,
            color: Colors.pink,
            description: 'Analyze your performance over time. See which habits you\'re mastering and where you can improve.',
            details: [
              '• Weekly and monthly completion rates.',
              '• Top performing habits.',
              '• Visual charts for progress tracking.',
            ],
          ),
          const SizedBox(height: 32),
          Consumer(builder: (context, ref, child) {
            return OutlinedButton.icon(
              onPressed: () async {
                context.push('/onboarding');
              },
              icon: const Icon(Icons.replay),
              label: const Text('Replay Introduction Tour'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> details,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          const Divider(),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  detail,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }
}
