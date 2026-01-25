
class UserListModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final bool active;
  final String? NFCTagID;

  const UserListModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.active,
    this.NFCTagID
  });

  factory UserListModel.fromJson(Map<String, dynamic> j) => UserListModel(
    id: (j['id'] as num?)?.toInt() ?? 0,
    username: (j['username'] ?? '') as String,
    firstName: (j['firstName'] ?? '') as String,
    lastName: (j['lastName'] ?? '') as String,
    active: (j['active'] ?? true) as bool,
    NFCTagID: j['NFCTagID'] as String?,
  );

  String get label {
    final name = '${firstName.trim()} ${lastName.trim()}'.trim();
    final base = name.isNotEmpty ? name : username;

    final nfc = (NFCTagID ?? '').trim();
    return nfc.isEmpty ? base : '$base | NFC: $nfc';
  }
}