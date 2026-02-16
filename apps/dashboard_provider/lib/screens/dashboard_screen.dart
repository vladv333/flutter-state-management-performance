import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../widgets/sensor_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedVolume = 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().initialize(_selectedVolume);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          Consumer<SensorProvider>(
            builder: (context, provider, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    provider.isUpdating ? 'UPDATING' : 'STOPPED',
                    style: TextStyle(
                      color: provider.isUpdating ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          _buildSensorInfo(),
          Expanded(
            child: _buildSensorList(),
          ),
        ],
      ),
    );
  }
  Widget _buildControlPanel() {
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
          Consumer<SensorProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: provider.isUpdating ? null : _startUpdates,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: provider.isUpdating ? _stopUpdates : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: provider.isUpdating ? null : _resetData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            },
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
        context.read<SensorProvider>().initialize(volume);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildSensorInfo() {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Total Sensors: ${provider.sensorCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Status: ${provider.isUpdating ? "Running" : "Idle"}',
                style: TextStyle(
                  color: provider.isUpdating ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorList() {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        if (provider.sensors.isEmpty) {
          return const Center(
            child: Text('No sensors loaded. Select volume and press Reset.'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: provider.sensors.length,
          itemBuilder: (context, index) {
            return SensorItemWidget(sensor: provider.sensors[index]);
          },
        );
      },
    );
  }

  void _startUpdates() {
    context.read<SensorProvider>().startUpdates();
  }

  void _stopUpdates() {
    context.read<SensorProvider>().stopUpdates();
  }

  void _resetData() {
    context.read<SensorProvider>()
      ..reset()
      ..initialize(_selectedVolume);
  }
}