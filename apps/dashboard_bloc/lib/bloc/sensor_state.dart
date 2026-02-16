import 'package:equatable/equatable.dart';
import '../models/sensor_data.dart';

abstract class SensorState extends Equatable {
  final List<SensorData> sensors;
  final bool isUpdating;

  const SensorState({
    required this.sensors,
    required this.isUpdating,
  });

  int get sensorCount => sensors.length;

  @override
  List<Object?> get props => [sensors, isUpdating];
}

class SensorInitial extends SensorState {
  const SensorInitial()
      : super(
    sensors: const [],
    isUpdating: false,
  );
}

class SensorLoaded extends SensorState {
  const SensorLoaded({
    required List<SensorData> sensors,
    required bool isUpdating,
  }) : super(
    sensors: sensors,
    isUpdating: isUpdating,
  );

  SensorLoaded copyWith({
    List<SensorData>? sensors,
    bool? isUpdating,
  }) {
    return SensorLoaded(
      sensors: sensors ?? this.sensors,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}