import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role; // 'employee' or 'admin'
  final String department;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department = 'General',
    this.token,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isEmployee => role.toLowerCase() == 'employee';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'employee',
      department: json['department'] as String? ?? 'General',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? department,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, department, token];
}

