import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import '../../../core/widgets/app_drawer.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoryAsync = ref.watch(categoryRepositoryProvider);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: repositoryAsync.when(
        data: (repository) {
          return StreamBuilder<List<Category>>(
            stream: repository.watchCategories(),
            initialData: repository.getAllCategories(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const Center(
                  child: Text('No categories yet. Add one!'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(category.color),
                        child: Icon(
                          IconData(category.icon, fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(category.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repository.deleteCategory(category.id),
                      ),
                      onTap: () => context.push('/categories/edit/${category.id}'),
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
        onPressed: () => context.push('/categories/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
