import 'package:flutter_test/flutter_test.dart';
import 'package:smart_qr_based_attendance_app/features/auth/data/models/user_model.dart';
import 'package:smart_qr_based_attendance_app/features/employee/data/models/attendance_model.dart';

void main() {
  test('UserModel serialization test', () {
    const user = UserModel(
      id: 1,
      name: 'Justin Johnson',
      email: 'employee@test.com',
      role: 'employee',
      department: 'Operations',
      token: 'mock_jwt_token',
    );

    expect(user.isAdmin, false);
    expect(user.isEmployee, true);
    final json = user.toJson();
    final parsed = UserModel.fromJson(json);
    expect(parsed.name, 'Justin Johnson');
    expect(parsed.email, 'employee@test.com');
  });

  test('AttendanceModel serialization test', () {
    final att = AttendanceModel.fromJson({
      'id': 101,
      'userId': 1,
      'sessionId': 'SESS_123',
      'date': '2026-11-12',
      'checkIn': '2026-11-12T09:00:00Z',
      'checkOut': '2026-11-12T17:00:00Z',
      'latitude': 10.0889,
      'longitude': 77.0595,
      'status': 'present',
    });

    expect(att.id, 101);
    expect(att.isCheckedIn, true);
    expect(att.isCheckedOut, true);
    expect(att.isLate, false);
  });
}
