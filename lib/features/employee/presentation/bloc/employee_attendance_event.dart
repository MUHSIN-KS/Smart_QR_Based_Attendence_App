import 'package:equatable/equatable.dart';

abstract class EmployeeAttendanceEvent extends Equatable {
  const EmployeeAttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployeeAttendance extends EmployeeAttendanceEvent {}

class RefreshEmployeeAttendance extends EmployeeAttendanceEvent {}

