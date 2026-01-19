/// Subfolder model class for grouping password entries.
///
/// Subfolders allow organizing multiple accounts under a category,
/// e.g., "Mobile Legends" and "Genshin Impact" under "Games" category.
class SubfolderModel {
  final int? id;
  final String name;
  final String category;

  SubfolderModel({this.id, required this.name, required this.category});

  /// Converts the model to a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'category': category};
  }

  /// Creates a SubfolderModel from a database Map.
  factory SubfolderModel.fromMap(Map<String, dynamic> map) {
    return SubfolderModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
    );
  }

  /// Creates a copy of this model with optional new values.
  SubfolderModel copyWith({int? id, String? name, String? category}) {
    return SubfolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'SubfolderModel(id: $id, name: $name, category: $category)';
  }
}
