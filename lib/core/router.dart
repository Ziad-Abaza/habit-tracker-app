import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/habits/presentation/habit_list_screen.dart';
import '../../features/habits/presentation/add_habit_screen.dart';
import '../../features/schedule/presentation/template_list_screen.dart';
import '../../features/schedule/presentation/edit_template_screen.dart';
import '../../features/schedule/presentation/timeline_view_screen.dart';
import '../../features/schedule/presentation/add_time_block_screen.dart';
import '../../features/schedule/presentation/activity_details_screen.dart';
import '../../features/categories/presentation/category_list_screen.dart';
import '../../features/categories/presentation/add_category_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/guide_screen.dart';
import '../../features/settings/presentation/settings_controller.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final hasSeenOnboarding = ref.watch(
    settingsControllerProvider.select((s) => s.hasSeenOnboarding),
  );

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!hasSeenOnboarding && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) => const GuideScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HabitListScreen(),
        routes: [
          GoRoute(
            path: 'add-habit',
            builder: (context, state) => const AddHabitScreen(),
          ),
          GoRoute(
            path: 'edit-habit/:id',
            builder: (context, state) => AddHabitScreen(habitId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplateListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const EditTemplateScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => EditTemplateScreen(templateId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const TimelineViewScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddTimeBlockScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => AddTimeBlockScreen(blockId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'activity/:id',
            builder: (context, state) => ActivityDetailsScreen(
              activityId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddCategoryScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return AddCategoryScreen(categoryId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
    ],
  );
}
