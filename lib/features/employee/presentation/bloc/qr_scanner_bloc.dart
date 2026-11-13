import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/services/location_service.dart';
import '../../data/repositories/attendance_repository.dart';
import 'qr_scanner_event.dart';
import 'qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  final AttendanceRepository _attendanceRepository;
  final LocationService _locationService;

  QrScannerBloc({
    required AttendanceRepository attendanceRepository,
    required LocationService locationService,
  })  : _attendanceRepository = attendanceRepository,
        _locationService = locationService,
        super(QrScannerInitial()) {
    on<QrScannerStarted>((event, emit) => emit(QrScannerScanning()));
    on<QrScannerReset>((event, emit) => emit(QrScannerScanning()));
    on<QrCodeDetected>(_onQrCodeDetected);
  }

  Future<void> _onQrCodeDetected(
    QrCodeDetected event,
    Emitter<QrScannerState> emit,
  ) async {
    final token = event.rawCode.trim();
    if (token.isEmpty) {
      emit(const QrScannerFailure(message: 'Scanned QR code is empty.'));
      return;
    }

    emit(QrScannerValidating(token));

    try {
      // 1. Capture GPS location
      final location = await _locationService.getCurrentLocation();

      // 2. Perform check-in or check-out via REST API
      if (event.isCheckOut) {
        final result = await _attendanceRepository.markCheckOut(
          qrToken: token,
          latitude: location.latitude,
          longitude: location.longitude,
        );
        emit(
          QrScannerSuccess(
            attendance: result,
            isCheckOut: true,
            message: 'Check-out completed successfully!',
          ),
        );
      } else {
        final result = await _attendanceRepository.markCheckIn(
          qrToken: token,
          latitude: location.latitude,
          longitude: location.longitude,
        );
        emit(
          QrScannerSuccess(
            attendance: result,
            isCheckOut: false,
            message: 'Check-in recorded successfully!',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(QrScannerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      emit(QrScannerFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}

