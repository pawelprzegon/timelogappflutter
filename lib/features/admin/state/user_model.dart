
class UserListModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final bool active;

  const UserListModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.active,
  });

  factory UserListModel.fromJson(Map<String, dynamic> j) => UserListModel(
    id: j['id'] as int,
    username: (j['username'] ?? '') as String,
    firstName: (j['firstName'] ?? '') as String,
    lastName: (j['lastName'] ?? '') as String,
    active: (j['active'] ?? true) as bool,
  );

  String get label {
    final full = '${firstName.trim()} ${lastName.trim()}'.trim();
    return full.isNotEmpty ? full : username;
  }
}