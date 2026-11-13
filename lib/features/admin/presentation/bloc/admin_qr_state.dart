import 'package:equatable/equatable.dart';
import '../../data/models/admin_dashboard_model.dart';

abstract class AdminQrState extends Equatable {
  const AdminQrState();

  @override
  List<Object?> get props => [];
}

class AdminQrInitial extends AdminQrState {}

class AdminQrLoading extends AdminQrState {}

class AdminQrActive extends AdminQrState {
  final ActiveSessionModel session;
  final int currentRemainingSeconds;

  const AdminQrActive({
    required this.session,
    required this.currentRemainingSeconds,
  });

  bool get isExpired => currentRemainingSeconds <= 0;

  @override
  List<Object?> get props => [session, currentRemainingSeconds];
}

class AdminQrNoActiveSession extends AdminQrState {}

class AdminQrError extends AdminQrState {
  final String message;

  const AdminQrError(this.message);

  @override
  List<Object?> get props => [message];
}

