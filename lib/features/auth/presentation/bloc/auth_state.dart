import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  /// True when the error is a network/connection issue (not a server HTTP error).
  bool get isConnectionError =>
      message.contains('timed out') ||
      message.contains('connect') ||
      message.contains('reach server') ||
      message.contains('network') ||
      message.contains('SocketException');

  @override
  List<Object?> get props => [message];
}

