import 'package:equatable/equatable.dart';

abstract class AdminQrEvent extends Equatable {
  const AdminQrEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentSession extends AdminQrEvent {}

class GenerateNewSession extends AdminQrEvent {
  final int validityMinutes;

  const GenerateNewSession({this.validityMinutes = 2});

  @override
  List<Object?> get props => [validityMinutes];
}

class TimerTicked extends AdminQrEvent {
  final int remainingSeconds;

  const TimerTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

