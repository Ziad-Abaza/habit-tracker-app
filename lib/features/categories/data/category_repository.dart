import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/category.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final Box<Category> _box;

  CategoryRepository(this._box);

  static Future<CategoryRepository> init() async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    final box = await Hive.openBox<Category>('categories');
    return CategoryRepository(box);
  }

  List<Category> getAllCategories() {
    return _box.values.toList();
  }

  Future<void> addCategory(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  Stream<List<Category>> watchCategories() {
    return _box.watch().map((event) => _box.values.toList());
  }
}

@riverpod
Future<CategoryRepository> categoryRepository(Ref ref) async {
  return CategoryRepository.init();
}
