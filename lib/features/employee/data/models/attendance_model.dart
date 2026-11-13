import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_time_utils.dart';

class AttendanceModel extends Equatable {
  final int id;
  final int userId;
  final String? sessionId;
  final String date; // YYYY-MM-DD
  final String? checkIn; // ISO String
  final String? checkOut; // ISO String
  final double? latitudeIn;
  final double? longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String status; // 'present', 'late'

  const AttendanceModel({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.latitudeIn,
    this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
    this.status = 'present',
  });

  bool get isCheckedIn => checkIn != null && checkIn!.isNotEmpty;
  bool get isCheckedOut => checkOut != null && checkOut!.isNotEmpty;
  bool get isLate => status.toLowerCase() == 'late';

  String get checkInFormatted => DateTimeUtils.formatIsoTimeString(checkIn);
  String get checkOutFormatted => DateTimeUtils.formatIsoTimeString(checkOut);
  String get dateFormatted => DateTimeUtils.formatIsoDateString(checkIn ?? date);
  String get durationText => DateTimeUtils.calculateDuration(checkIn, checkOut);

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : (json['userId'] is int
              ? json['userId'] as int
              : int.tryParse(json['user_id']?.toString() ?? json['userId']?.toString() ?? '0') ?? 0),
      sessionId: json['session_id'] as String? ?? json['sessionId'] as String?,
      date: json['date'] as String? ?? '',
      checkIn: json['check_in'] as String? ?? json['checkIn'] as String?,
      checkOut: json['check_out'] as String? ?? json['checkOut'] as String?,
      latitudeIn: _parseDouble(json['latitude_in'] ?? json['latitude']),
      longitudeIn: _parseDouble(json['longitude_in'] ?? json['longitude']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'date': date,
      'check_in': checkIn,
      'check_out': checkOut,
      'latitude_in': latitudeIn,
      'longitude_in': longitudeIn,
      'latitude_out': latitudeOut,
      'longitude_out': longitudeOut,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        date,
        checkIn,
        checkOut,
        latitudeIn,
        longitudeIn,
        latitudeOut,
        longitudeOut,
        status,
      ];
}

