import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<AttendanceModel?> getTodayAttendance() async {
    final response = await _apiClient.get(ApiEndpoints.todayAttendance);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return AttendanceModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final response = await _apiClient.get(ApiEndpoints.attendanceHistory);
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<AttendanceModel> markCheckIn({
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.checkIn,
      data: {
        'qrToken': qrToken.trim(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      return AttendanceModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to record check-in.');
  }

  Future<AttendanceModel> markCheckOut({
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.checkOut,
      data: {
        'qrToken': qrToken.trim(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      return AttendanceModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to record check-out.');
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    final response = await _apiClient.get(ApiEndpoints.activeSession);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }
}

