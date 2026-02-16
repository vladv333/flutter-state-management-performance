import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/sensor_store.dart';
import '../widgets/sensor_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final SensorStore _store = SensorStore();
  int _selectedVolume = 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.initialize(_selectedVolume);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MobX Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          Observer(
            builder: (_) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _store.isUpdating ? 'UPDATING' : 'STOPPED',
                  style: TextStyle(
                    color: _store.isUpdating ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          _buildSensorInfo(),
          Expanded(child: _buildSensorList()),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[200],
        child: Column(
          children: [
            Row(
              children: [
                const Text('Data Volume: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: _store.isUpdating ? null : _store.startUpdates,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _store.isUpdating ? _store.stopUpdates : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _store.isUpdating ? null : _resetData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeButton(int volume) {
    final isSelected = _selectedVolume == volume;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedVolume = volume);
        _store.initialize(volume);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildSensorInfo() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Total Sensors: ${_store.sensorCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Status: ${_store.isUpdating ? "Running" : "Idle"}',
              style: TextStyle(
                color: _store.isUpdating ? Colors.teal : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorList() {
    return Observer(
      builder: (_) {
        if (_store.sensors.isEmpty) {
          return const Center(
            child: Text('No sensors loaded. Select volume and press Reset.'),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: _store.sensors.length,
          itemBuilder: (context, index) {
            return SensorItemWidget(sensor: _store.sensors[index]);
          },
        );
      },
    );
  }

  void _resetData() {
    _store..reset()..initialize(_selectedVolume);
  }
}