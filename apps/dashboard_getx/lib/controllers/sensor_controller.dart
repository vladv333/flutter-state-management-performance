import 'dart:async';
import 'package:get/get.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';

class SensorController extends GetxController {
  final MockDataService _dataService = MockDataService();
  Timer? _updateTimer;

  final sensors = <SensorData>[].obs;
  final isUpdating = false.obs;

  // Computed property
  int get sensorCount => sensors.length;

  void initialize(int count) {
    final newSensors = _dataService.generateSensors(count);
    sensors.value = newSensors;
    isUpdating.value = false;
  }

  void startUpdates() {
    if (isUpdating.value) return;

    isUpdating.value = true;

    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        _updateAllSensors();
      },
    );
  }

  void stopUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    isUpdating.value = false;
  }

  void _updateAllSensors() {
    // GetX оптимизация: обновляем in-place
    for (int i = 0; i < sensors.length; i++) {
      sensors[i] = _dataService.updateSensor(sensors[i]);
    }

    sensors.refresh();
  }

  void reset() {
    stopUpdates();
    sensors.clear();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }
}