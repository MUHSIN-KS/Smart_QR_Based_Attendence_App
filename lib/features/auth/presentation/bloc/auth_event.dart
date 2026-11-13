import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String department;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    this.role = 'employee',
    this.department = 'Operations',
  });

  @override
  List<Object?> get props => [name, email, password, role, department];
}

class LogoutRequested extends AuthEvent {}

