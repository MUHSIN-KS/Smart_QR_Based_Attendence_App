import 'package:equatable/equatable.dart';
import '../../data/models/admin_dashboard_model.dart';
import '../../data/models/employee_model.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardModel dashboard;
  final List<AdminAttendanceRecord> recentRecords;

  const AdminDashboardLoaded({
    required this.dashboard,
    required this.recentRecords,
  });

  @override
  List<Object?> get props => [dashboard, recentRecords];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

