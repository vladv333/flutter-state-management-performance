import 'dart:math';
import '../models/sensor_data.dart';

class MockDataService {
  final Random _random = Random();

  List<SensorData> generateSensors(int count) {
    final List<SensorData> sensors = [];
    for (int i = 0; i < count; i++) {
      final category = SensorCategory.all[i % SensorCategory.all.length];
      sensors.add(_createSensor(i, category));
    }
    return sensors;
  }

  SensorData _createSensor(int index, String category) {
    return SensorData(
      id: 'sensor_$index',
      category: category,
      value: _getInitialValue(category),
      unit: _getUnit(category),
      timestamp: DateTime.now(),
    );
  }

  SensorData updateSensor(SensorData sensor) {
    return sensor.copyWith(
      value: _getUpdatedValue(sensor.category, sensor.value),
      timestamp: DateTime.now(),
    );
  }

  double _getInitialValue(String category) {
    switch (category) {
      case SensorCategory.temperature:
        return 15.0 + _random.nextDouble() * 20.0;
      case SensorCategory.humidity:
        return 30.0 + _random.nextDouble() * 50.0;
      case SensorCategory.pressure:
        return 980.0 + _random.nextDouble() * 60.0;
      case SensorCategory.speed:
        return _random.nextDouble() * 120.0;
      case SensorCategory.light:
        return _random.nextDouble() * 1000.0;
      default:
        return _random.nextDouble() * 100.0;
    }
  }

  double _getUpdatedValue(String category, double currentValue) {
    final change = (currentValue * 0.05) * (_random.nextDouble() * 2 - 1);
    final newValue = currentValue + change;

    switch (category) {
      case SensorCategory.temperature:
        return newValue.clamp(15.0, 35.0);
      case SensorCategory.humidity:
        return newValue.clamp(30.0, 80.0);
      case SensorCategory.pressure:
        return newValue.clamp(980.0, 1040.0);
      case SensorCategory.speed:
        return newValue.clamp(0.0, 120.0);
      case SensorCategory.light:
        return newValue.clamp(0.0, 1000.0);
      default:
        return newValue.clamp(0.0, 100.0);
    }
  }

  String _getUnit(String category) {
    switch (category) {
      case SensorCategory.temperature:
        return '°C';
      case SensorCategory.humidity:
        return '%';
      case SensorCategory.pressure:
        return 'hPa';
      case SensorCategory.speed:
        return 'km/h';
      case SensorCategory.light:
        return 'lux';
      default:
        return '';
    }
  }
}