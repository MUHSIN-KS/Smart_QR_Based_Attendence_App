import 'package:equatable/equatable.dart';
import '../../data/models/attendance_model.dart';

abstract class EmployeeAttendanceState extends Equatable {
  const EmployeeAttendanceState();

  @override
  List<Object?> get props => [];
}

class EmployeeAttendanceInitial extends EmployeeAttendanceState {}

class EmployeeAttendanceLoading extends EmployeeAttendanceState {}

class EmployeeAttendanceLoaded extends EmployeeAttendanceState {
  final AttendanceModel? todayRecord;
  final List<AttendanceModel> history;

  const EmployeeAttendanceLoaded({
    this.todayRecord,
    required this.history,
  });

  bool get isCheckedInToday => todayRecord != null && todayRecord!.isCheckedIn;
  bool get isCheckedOutToday => todayRecord != null && todayRecord!.isCheckedOut;

  @override
  List<Object?> get props => [todayRecord, history];
}

class EmployeeAttendanceError extends EmployeeAttendanceState {
  final String message;

  const EmployeeAttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

