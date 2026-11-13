class ApiEndpoints {
  // Authentication
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';

  // QR Code Management (Admin)
  static const String createSession = '/api/attendance/session';
  static const String activeSession = '/api/attendance/session/active';
  static String sessionDetails(String id) => '/api/attendance/session/$id';

  // Employee Attendance
  static const String checkIn = '/api/attendance/check-in';
  static const String checkOut = '/api/attendance/check-out';
  static const String attendanceHistory = '/api/attendance/history';
  static const String todayAttendance = '/api/attendance/today';

  // Admin Dashboard
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminEmployees = '/api/admin/employees';
  static const String adminAttendance = '/api/admin/attendance';
  static String adminAttendanceDetails(int id) => '/api/admin/attendance/$id';
}

