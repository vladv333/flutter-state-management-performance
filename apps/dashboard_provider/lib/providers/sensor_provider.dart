import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';

class SensorProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  List<SensorData> _sensors = [];
  bool _isUpdating = false;
  Timer? _updateTimer;

  // Getters
  List<SensorData> get sensors => _sensors;
  bool get isUpdating => _isUpdating;
  int get sensorCount => _sensors.length;

  void initialize(int count) {
    _sensors = _dataService.generateSensors(count);
    notifyListeners();
  }

  void startUpdates() {
    if (_isUpdating) return;

    _isUpdating = true;
    notifyListeners();

    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateAllSensors();
    });
  }

  void stopUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _isUpdating = false;
    notifyListeners();
  }

  void _updateAllSensors() {
    for (int i = 0; i < _sensors.length; i++) {
      _sensors[i] = _dataService.updateSensor(_sensors[i]);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void reset() {
    stopUpdates();
    _sensors = [];
    notifyListeners();
  }
}