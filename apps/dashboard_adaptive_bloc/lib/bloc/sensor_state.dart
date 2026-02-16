import 'package:equatable/equatable.dart';
import '../models/sensor_data.dart';

// Enum for strategies
enum UpdateStrategy {
  normal,      // UPDATE ALL
  lightweight, // UPDATE ONLY VISIBLE
}

abstract class SensorState extends Equatable {
  final List<SensorData> sensors;
  final bool isUpdating;
  final UpdateStrategy strategy;
  final int switchCount;

  const SensorState({
    required this.sensors,
    required this.isUpdating,
    this.strategy = UpdateStrategy.normal,
    this.switchCount = 0,
  });

  int get sensorCount => sensors.length;

  @override
  List<Object?> get props => [sensors, isUpdating, strategy, switchCount];
}

class SensorInitial extends SensorState {
  const SensorInitial()
      : super(
    sensors: const [],
    isUpdating: false,
    strategy: UpdateStrategy.normal,
    switchCount: 0,
  );
}

class SensorLoaded extends SensorState {
  const SensorLoaded({
    required List<SensorData> sensors,
    required bool isUpdating,
    UpdateStrategy strategy = UpdateStrategy.normal,
    int switchCount = 0,
  }) : super(
    sensors: sensors,
    isUpdating: isUpdating,
    strategy: strategy,
    switchCount: switchCount,
  );

  SensorLoaded copyWith({
    List<SensorData>? sensors,
    bool? isUpdating,
    UpdateStrategy? strategy,
    int? switchCount,
  }) {
    return SensorLoaded(
      sensors: sensors ?? this.sensors,
      isUpdating: isUpdating ?? this.isUpdating,
      strategy: strategy ?? this.strategy,
      switchCount: switchCount ?? this.switchCount,
    );
  }
}