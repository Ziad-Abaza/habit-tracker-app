import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/habits/presentation/habit_list_screen.dart';
import '../../features/habits/presentation/add_habit_screen.dart';
import '../../features/schedule/presentation/template_list_screen.dart';
import '../../features/schedule/presentation/edit_template_screen.dart';
import '../../features/schedule/presentation/timeline_view_screen.dart';
import '../../features/schedule/presentation/add_time_block_screen.dart';
import '../../features/categories/presentation/category_list_screen.dart';
import '../../features/categories/presentation/add_category_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
    ],
  );
}
