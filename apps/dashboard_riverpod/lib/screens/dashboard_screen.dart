import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sensor_provider.dart';
import '../widgets/sensor_item_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedVolume = 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sensorProvider.notifier).initialize(_selectedVolume);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorState = ref.watch(sensorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sensorState.isUpdating ? 'UPDATING' : 'STOPPED',
                style: TextStyle(
                  color: sensorState.isUpdating ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(sensorState),
          _buildSensorInfo(sensorState),
          Expanded(
            child: _buildSensorList(sensorState),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(SensorState sensorState) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          Row(
            children: [
              const Text('Data Volume: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              _buildVolumeButton(1000),
              const SizedBox(width: 8),
              _buildVolumeButton(5000),
              const SizedBox(width: 8),
              _buildVolumeButton(10000),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: sensorState.isUpdating ? null : _startUpdates,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: sensorState.isUpdating ? _stopUpdates : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: sensorState.isUpdating ? null : _resetData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeButton(int volume) {
    final isSelected = _selectedVolume == volume;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedVolume = volume;
        });
        ref.read(sensorProvider.notifier).initialize(volume);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildSensorInfo(SensorState sensorState) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.green[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Total Sensors: ${sensorState.sensorCount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Status: ${sensorState.isUpdating ? "Running" : "Idle"}',
            style: TextStyle(
              color: sensorState.isUpdating ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorList(SensorState sensorState) {
    if (sensorState.sensors.isEmpty) {
      return const Center(
        child: Text('No sensors loaded. Select volume and press Reset.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: sensorState.sensors.length,
      itemBuilder: (context, index) {
        return SensorItemWidget(sensor: sensorState.sensors[index]);
      },
    );
  }

  void _startUpdates() {
    ref.read(sensorProvider.notifier).startUpdates();
  }

  void _stopUpdates() {
    ref.read(sensorProvider.notifier).stopUpdates();
  }

  void _resetData() {
    ref.read(sensorProvider.notifier)
      ..reset()
      ..initialize(_selectedVolume);
  }
}