import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRepository _adminRepository;

  AdminDashboardBloc(this._adminRepository) : super(AdminDashboardInitial()) {
    on<LoadAdminDashboard>(_onLoadDashboard);
    on<RefreshAdminDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(AdminDashboardLoading());
    try {
      final dashboard = await _adminRepository.getDashboard();
      final records = await _adminRepository.getAttendanceRecords();
      emit(AdminDashboardLoaded(dashboard: dashboard, recentRecords: records));
    } on ApiException catch (e) {
      emit(AdminDashboardError(e.message));
    } catch (e) {
      emit(AdminDashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshAdminDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    try {
      final dashboard = await _adminRepository.getDashboard();
      final records = await _adminRepository.getAttendanceRecords();
      emit(AdminDashboardLoaded(dashboard: dashboard, recentRecords: records));
    } catch (_) {
      // Keep previous state
    }
  }
}

