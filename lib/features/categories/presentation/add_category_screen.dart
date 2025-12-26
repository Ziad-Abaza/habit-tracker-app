import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import '../../../core/utils/icon_helper.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const AddCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.folder;

  final List<IconData> _icons = [
    Icons.work,
    Icons.school,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.home,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.flight,
    Icons.music_note,
    Icons.book,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    final repository = await ref.read(categoryRepositoryProvider.future);
    final categories = repository.getAllCategories();
    final category = categories.firstWhere((c) => c.id == widget.categoryId);
    
    setState(() {
      _nameController.text = category.name;
      _selectedColor = Color(category.color);
      _selectedIcon = IconHelper.getIconData(category.icon);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final repository = await ref.read(categoryRepositoryProvider.future);
      
      final category = Category(
        id: widget.categoryId ?? const Uuid().v4(),
        name: _nameController.text,
        color: _selectedColor.value,
        icon: _selectedIcon.codePoint,
      );

      if (widget.categoryId != null) {
        await repository.updateCategory(category);
      } else {
        await repository.addCategory(category);
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId != null ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Color'),
              trailing: CircleAvatar(backgroundColor: _selectedColor),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: _selectedColor,
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _icons.map((icon) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon ? Theme.of(context).colorScheme.primaryContainer : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedIcon == icon ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: _selectedIcon == icon ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCategory,
              child: Text(widget.categoryId != null ? 'Update Category' : 'Create Category'),
            ),
          ],
        ),
      ),
    );
  }
}
