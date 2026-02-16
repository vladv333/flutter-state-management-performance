class SensorData {
  final String id;
  final String category;
  final double value;
  final String unit;
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.category,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  SensorData copyWith({
    String? id,
    String? category,
    double? value,
    String? unit,
    DateTime? timestamp,
  }) {
    return SensorData(
      id: id ?? this.id,
      category: category ?? this.category,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class SensorCategory {
  static const String temperature = 'Temperature';
  static const String humidity = 'Humidity';
  static const String pressure = 'Pressure';
  static const String speed = 'Speed';
  static const String light = 'Light';

  static const List<String> all = [
    temperature,
    humidity,
    pressure,
    speed,
    light,
  ];
}