class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? createdAt;

  const AppUser({this.id, required this.name, required this.email, required this.passwordHash, this.createdAt});

  AppUser copyWith({int? id, String? name, String? email, String? passwordHash, String? createdAt}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt,
    };
  }
}
