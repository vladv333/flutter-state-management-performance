import 'package:equatable/equatable.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSensorsEvent extends SensorEvent {
  final int count;

  const InitializeSensorsEvent(this.count);

  @override
  List<Object?> get props => [count];
}

class StartUpdatesEvent extends SensorEvent {
  const StartUpdatesEvent();
}

class StopUpdatesEvent extends SensorEvent {
  const StopUpdatesEvent();
}

class UpdateSensorsEvent extends SensorEvent {
  const UpdateSensorsEvent();
}

class ResetSensorsEvent extends SensorEvent {
  const ResetSensorsEvent();
}