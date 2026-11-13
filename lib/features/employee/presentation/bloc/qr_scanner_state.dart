import 'package:equatable/equatable.dart';
import '../../data/models/attendance_model.dart';

abstract class QrScannerState extends Equatable {
  const QrScannerState();

  @override
  List<Object?> get props => [];
}

class QrScannerInitial extends QrScannerState {}

class QrScannerScanning extends QrScannerState {}

class QrScannerValidating extends QrScannerState {
  final String qrToken;

  const QrScannerValidating(this.qrToken);

  @override
  List<Object?> get props => [qrToken];
}

class QrScannerSuccess extends QrScannerState {
  final AttendanceModel attendance;
  final bool isCheckOut;
  final String message;

  const QrScannerSuccess({
    required this.attendance,
    required this.isCheckOut,
    required this.message,
  });

  @override
  List<Object?> get props => [attendance, isCheckOut, message];
}

class QrScannerFailure extends QrScannerState {
  final String message;
  final int? statusCode;

  const QrScannerFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

