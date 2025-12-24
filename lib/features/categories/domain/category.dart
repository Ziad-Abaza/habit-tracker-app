import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int color; // ARGB int

  @HiveField(3)
  final int icon; // CodePoint

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Category copyWith({
    String? id,
    String? name,
    int? color,
    int? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
