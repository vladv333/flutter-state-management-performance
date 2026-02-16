import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class SensorItemWidget extends StatelessWidget {
  final SensorData sensor;

  const SensorItemWidget({
    Key? key,
    required this.sensor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildCategoryIcon(),
        title: Text(
          sensor.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('ID: ${sensor.id}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${sensor.value.toStringAsFixed(1)} ${sensor.unit}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _formatTimestamp(sensor.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData iconData;
    Color color;

    switch (sensor.category) {
      case 'Temperature':
        iconData = Icons.thermostat;
        color = Colors.red;
        break;
      case 'Humidity':
        iconData = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'Pressure':
        iconData = Icons.compress;
        color = Colors.purple;
        break;
      case 'Speed':
        iconData = Icons.speed;
        color = Colors.orange;
        break;
      case 'Light':
        iconData = Icons.wb_sunny;
        color = Colors.yellow;
        break;
      default:
        iconData = Icons.sensors;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${(timestamp.millisecond ~/ 100)}';
  }
}