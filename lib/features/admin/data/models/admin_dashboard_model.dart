import 'package:equatable/equatable.dart';

class ActiveSessionModel extends Equatable {
  final String sessionId;
  final String qrToken;
  final int validityMinutes;
  final String createdAt;
  final String expiresAt;
  final bool isExpired;
  final int remainingSeconds;

  const ActiveSessionModel({
    required this.sessionId,
    required this.qrToken,
    required this.validityMinutes,
    required this.createdAt,
    required this.expiresAt,
    required this.isExpired,
    required this.remainingSeconds,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      sessionId: json['sessionId'] as String? ?? '',
      qrToken: json['qrToken'] as String? ?? '',
      validityMinutes: json['validityMinutes'] is int
          ? json['validityMinutes'] as int
          : int.tryParse(json['validityMinutes']?.toString() ?? '2') ?? 2,
      createdAt: json['createdAt'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
      isExpired: json['isExpired'] as bool? ?? false,
      remainingSeconds: json['remainingSeconds'] is int
          ? json['remainingSeconds'] as int
          : int.tryParse(json['remainingSeconds']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        qrToken,
        validityMinutes,
        createdAt,
        expiresAt,
        isExpired,
        remainingSeconds,
      ];
}

class AdminDashboardModel extends Equatable {
  final String today;
  final int totalEmployees;
  final int present;
  final int absent;
  final int late;
  final ActiveSessionModel? activeSession;

  const AdminDashboardModel({
    required this.today,
    required this.totalEmployees,
    required this.present,
    required this.absent,
    required this.late,
    this.activeSession,
  });

  double get attendanceRate =>
      totalEmployees > 0 ? (present / totalEmployees) * 100 : 0.0;

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      today: json['today'] as String? ?? '',
      totalEmployees: json['totalEmployees'] is int
          ? json['totalEmployees'] as int
          : int.tryParse(json['totalEmployees']?.toString() ?? '0') ?? 0,
      present: json['present'] is int
          ? json['present'] as int
          : int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      absent: json['absent'] is int
          ? json['absent'] as int
          : int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      late: json['late'] is int
          ? json['late'] as int
          : int.tryParse(json['late']?.toString() ?? '0') ?? 0,
      activeSession: json['activeSession'] != null
          ? ActiveSessionModel.fromJson(json['activeSession'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        today,
        totalEmployees,
        present,
        absent,
        late,
        activeSession,
      ];
}

