import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_time_utils.dart';

class EmployeeModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String department;
  final String role;
  final String? createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      department: json['department'] as String? ?? 'General',
      role: json['role'] as String? ?? 'employee',
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, email, department, role, createdAt];
}

class AdminAttendanceRecord extends Equatable {
  final int id;
  final int userId;
  final String employeeName;
  final String employeeEmail;
  final String department;
  final String sessionId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double? latitudeIn;
  final double? longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String status;

  const AdminAttendanceRecord({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.employeeEmail,
    required this.department,
    required this.sessionId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.latitudeIn,
    this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
    required this.status,
  });

  bool get isLate => status.toLowerCase() == 'late';
  String get checkInFormatted => DateTimeUtils.formatIsoTimeString(checkIn);
  String get checkOutFormatted => DateTimeUtils.formatIsoTimeString(checkOut);
  String get durationText => DateTimeUtils.calculateDuration(checkIn, checkOut);

  factory AdminAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceRecord(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      employeeName: json['employee_name'] as String? ?? 'Employee',
      employeeEmail: json['employee_email'] as String? ?? '',
      department: json['department'] as String? ?? 'General',
      sessionId: json['session_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      latitudeIn: _parseDouble(json['latitude_in']),
      longitudeIn: _parseDouble(json['longitude_in']),
      latitudeOut: _parseDouble(json['latitude_out']),
      longitudeOut: _parseDouble(json['longitude_out']),
      status: json['status'] as String? ?? 'present',
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        employeeName,
        employeeEmail,
        department,
        sessionId,
        date,
        checkIn,
        checkOut,
        status,
      ];
}

