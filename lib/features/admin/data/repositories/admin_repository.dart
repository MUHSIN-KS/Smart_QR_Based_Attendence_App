import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/admin_dashboard_model.dart';
import '../models/employee_model.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  Future<AdminDashboardModel> getDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.adminDashboard);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return AdminDashboardModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load admin dashboard');
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final response = await _apiClient.get(ApiEndpoints.adminEmployees);
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AdminAttendanceRecord>> getAttendanceRecords({
    String? date,
    int? userId,
  }) async {
    final Map<String, dynamic> query = {};
    if (date != null && date.isNotEmpty) query['date'] = date;
    if (userId != null) query['userId'] = userId;

    final response = await _apiClient.get(
      ApiEndpoints.adminAttendance,
      queryParameters: query.isNotEmpty ? query : null,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => AdminAttendanceRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ActiveSessionModel> createSession({int validityMinutes = 2}) async {
    final response = await _apiClient.post(
      ApiEndpoints.createSession,
      data: {'validityMinutes': validityMinutes},
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      return ActiveSessionModel(
        sessionId: data['sessionId'] as String? ?? '',
        qrToken: data['qrToken'] as String? ?? '',
        validityMinutes: data['validityMinutes'] is int
            ? data['validityMinutes'] as int
            : int.tryParse(data['validityMinutes']?.toString() ?? '2') ?? 2,
        createdAt: data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        expiresAt: data['expiresAt'] as String? ?? '',
        isExpired: false,
        remainingSeconds: (validityMinutes * 60),
      );
    }

    throw Exception('Failed to generate attendance QR session');
  }

  Future<ActiveSessionModel?> getActiveSession() async {
    final response = await _apiClient.get(ApiEndpoints.activeSession);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return ActiveSessionModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }
}

