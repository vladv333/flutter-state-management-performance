import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';

class SensorState {
  final List<SensorData> sensors;
  final bool isUpdating;

  SensorState({
    required this.sensors,
    required this.isUpdating,
  });

  SensorState copyWith({
    List<SensorData>? sensors,
    bool? isUpdating,
  }) {
    return SensorState(
      sensors: sensors ?? this.sensors,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  int get sensorCount => sensors.length;
}

class SensorNotifier extends Notifier<SensorState> {
  final MockDataService _dataService = MockDataService();
  Timer? _updateTimer;

  @override
  SensorState build() {
    // Очистка при dispose
    ref.onDispose(() {
      _updateTimer?.cancel();
    });

    return SensorState(
      sensors: [],
      isUpdating: false,
    );
  }

  void initialize(int count) {
    final sensors = _dataService.generateSensors(count);
    state = state.copyWith(sensors: sensors, isUpdating: false);
  }

  void startUpdates() {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true);

    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateAllSensors();
    });
  }

  void stopUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    state = state.copyWith(isUpdating: false);
  }

  void _updateAllSensors() {
    final updatedSensors = state.sensors.map((sensor) {
      return _dataService.updateSensor(sensor);
    }).toList();

    state = state.copyWith(sensors: updatedSensors);
  }

  void reset() {
    stopUpdates();
    state = SensorState(sensors: [], isUpdating: false);
  }
}

final sensorProvider = NotifierProvider<SensorNotifier, SensorState>(() {
  return SensorNotifier();
});