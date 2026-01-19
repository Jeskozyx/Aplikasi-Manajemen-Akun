/// Password model class for managing password entries in the database.
///
/// Supports categorization with predefined categories and optional subfolder grouping.
class PasswordModel {
  final int? id;
  final String title;
  final String accountName;
  final String? email;
  final String? username;
  final String password;
  final bool isActive;
  final String category;
  final int? subfolderId;

  /// Available categories for password entries.
  static const List<String> categories = ['Games', 'Student', 'Google', 'App'];

  PasswordModel({
    this.id,
    required this.title,
    required this.accountName,
    this.email,
    this.username,
    required this.password,
    this.isActive = true,
    required this.category,
    this.subfolderId,
  });

  /// Converts the model to a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'account_name': accountName,
      'email': email,
      'username': username,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'category': category,
      'subfolder_id': subfolderId,
    };
  }

  /// Creates a PasswordModel from a database Map.
  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      accountName: map['account_name'] as String,
      email: map['email'] as String?,
      username: map['username'] as String?,
      password: map['password'] as String,
      isActive: (map['is_active'] as int) == 1,
      category: map['category'] as String,
      subfolderId: map['subfolder_id'] as int?,
    );
  }

  /// Creates a copy of this model with optional new values.
  PasswordModel copyWith({
    int? id,
    String? title,
    String? accountName,
    String? email,
    String? username,
    String? password,
    bool? isActive,
    String? category,
    int? subfolderId,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      accountName: accountName ?? this.accountName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      subfolderId: subfolderId ?? this.subfolderId,
    );
  }

  @override
  String toString() {
    return 'PasswordModel(id: $id, title: $title, accountName: $accountName, category: $category)';
  }
}
