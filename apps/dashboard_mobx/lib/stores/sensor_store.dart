import 'dart:async';
import 'package:mobx/mobx.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';

part 'sensor_store.g.dart';

class SensorStore = _SensorStore with _$SensorStore;

abstract class _SensorStore with Store {
  final MockDataService _dataService = MockDataService();
  Timer? _updateTimer;

  @observable
  ObservableList<SensorData> sensors = ObservableList<SensorData>();

  @observable
  bool isUpdating = false;

  @computed
  int get sensorCount => sensors.length;

  @action
  void initialize(int count) {
    final newSensors = _dataService.generateSensors(count);
    sensors.clear();
    sensors.addAll(newSensors);
    isUpdating = false;
  }

  @action
  void startUpdates() {
    if (isUpdating) return;
    isUpdating = true;
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) => _updateAllSensors(),
    );
  }

  @action
  void stopUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    isUpdating = false;
  }

  @action
  void _updateAllSensors() {
    for (int i = 0; i < sensors.length; i++) {
      sensors[i] = _dataService.updateSensor(sensors[i]);
    }
  }

  @action
  void reset() {
    stopUpdates();
    sensors.clear();
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}