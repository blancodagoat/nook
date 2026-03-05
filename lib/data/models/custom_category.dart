import 'package:isar/isar.dart';

part 'custom_category.g.dart';

@collection
class CustomCategory {

  CustomCategory({
    required this.name, required this.emoji, required this.type, this.id,
    this.colorHex = '#6366F1',
  });
  Id? id;

  @Index()
  String name;
  
  String emoji;
  
  @Index()
  String type;
  
  String colorHex;

  CustomCategory copyWith({
    Id? id,
    String? name,
    String? emoji,
    String? type,
    String? colorHex,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
