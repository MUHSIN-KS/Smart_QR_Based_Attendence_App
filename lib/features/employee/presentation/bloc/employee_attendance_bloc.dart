import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/attendance_repository.dart';
import 'employee_attendance_event.dart';
import 'employee_attendance_state.dart';

class EmployeeAttendanceBloc
    extends Bloc<EmployeeAttendanceEvent, EmployeeAttendanceState> {
  final AttendanceRepository _attendanceRepository;

  EmployeeAttendanceBloc(this._attendanceRepository)
      : super(EmployeeAttendanceInitial()) {
    on<LoadEmployeeAttendance>(_onLoadAttendance);
    on<RefreshEmployeeAttendance>(_onRefreshAttendance);
  }

  Future<void> _onLoadAttendance(
    LoadEmployeeAttendance event,
    Emitter<EmployeeAttendanceState> emit,
  ) async {
    emit(EmployeeAttendanceLoading());
    try {
      final today = await _attendanceRepository.getTodayAttendance();
      final history = await _attendanceRepository.getAttendanceHistory();
      emit(EmployeeAttendanceLoaded(todayRecord: today, history: history));
    } on ApiException catch (e) {
      emit(EmployeeAttendanceError(e.message));
    } catch (e) {
      emit(EmployeeAttendanceError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshAttendance(
    RefreshEmployeeAttendance event,
    Emitter<EmployeeAttendanceState> emit,
  ) async {
    try {
      final today = await _attendanceRepository.getTodayAttendance();
      final history = await _attendanceRepository.getAttendanceHistory();
      emit(EmployeeAttendanceLoaded(todayRecord: today, history: history));
    } catch (_) {
      // Keep previous state on refresh error
    }
  }
}

