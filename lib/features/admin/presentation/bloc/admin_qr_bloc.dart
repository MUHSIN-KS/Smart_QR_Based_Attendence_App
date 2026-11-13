import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_qr_event.dart';
import 'admin_qr_state.dart';

class AdminQrBloc extends Bloc<AdminQrEvent, AdminQrState> {
  final AdminRepository _adminRepository;
  Timer? _tickerTimer;

  AdminQrBloc(this._adminRepository) : super(AdminQrInitial()) {
    on<LoadCurrentSession>(_onLoadCurrentSession);
    on<GenerateNewSession>(_onGenerateNewSession);
    on<TimerTicked>(_onTimerTicked);
  }

  void _startTimer(int seconds) {
    _tickerTimer?.cancel();
    if (seconds <= 0) return;

    int remaining = seconds;
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      add(TimerTicked(remaining));
      if (remaining <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _onLoadCurrentSession(
    LoadCurrentSession event,
    Emitter<AdminQrState> emit,
  ) async {
    emit(AdminQrLoading());
    try {
      final session = await _adminRepository.getActiveSession();
      if (session != null && !session.isExpired && session.remainingSeconds > 0) {
        _startTimer(session.remainingSeconds);
        emit(AdminQrActive(
          session: session,
          currentRemainingSeconds: session.remainingSeconds,
        ));
      } else {
        emit(AdminQrNoActiveSession());
      }
    } on ApiException catch (e) {
      emit(AdminQrError(e.message));
    } catch (e) {
      emit(AdminQrError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGenerateNewSession(
    GenerateNewSession event,
    Emitter<AdminQrState> emit,
  ) async {
    emit(AdminQrLoading());
    try {
      final session = await _adminRepository.createSession(
        validityMinutes: event.validityMinutes,
      );
      _startTimer(session.remainingSeconds);
      emit(AdminQrActive(
        session: session,
        currentRemainingSeconds: session.remainingSeconds,
      ));
    } on ApiException catch (e) {
      emit(AdminQrError(e.message));
    } catch (e) {
      emit(AdminQrError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onTimerTicked(
    TimerTicked event,
    Emitter<AdminQrState> emit,
  ) {
    if (state is AdminQrActive) {
      final current = state as AdminQrActive;
      emit(AdminQrActive(
        session: current.session,
        currentRemainingSeconds: event.remainingSeconds,
      ));
    }
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    return super.close();
  }
}

