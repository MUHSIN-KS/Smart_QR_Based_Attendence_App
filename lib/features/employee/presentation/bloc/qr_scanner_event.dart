import 'package:equatable/equatable.dart';

abstract class QrScannerEvent extends Equatable {
  const QrScannerEvent();

  @override
  List<Object?> get props => [];
}

class QrScannerStarted extends QrScannerEvent {}

class QrCodeDetected extends QrScannerEvent {
  final String rawCode;
  final bool isCheckOut;

  const QrCodeDetected({
    required this.rawCode,
    this.isCheckOut = false,
  });

  @override
  List<Object?> get props => [rawCode, isCheckOut];
}

class QrScannerReset extends QrScannerEvent {}

