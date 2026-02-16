import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sensor_controller.dart';
import '../widgets/sensor_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final SensorController _controller = Get.put(SensorController());
  int _selectedVolume = 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(_selectedVolume);
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
        title: const Text('GetX Dashboard'),
        backgroundColor: Colors.orange,
        actions: [
          // Obx - GetX reactive widget
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _controller.isUpdating.value ? 'UPDATING' : 'STOPPED',
                style: TextStyle(
                  color: _controller.isUpdating.value
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
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
    return Obx(() {
      final isUpdating = _controller.isUpdating.value;

      return Container(
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
                  onPressed: isUpdating ? null : _controller.startUpdates,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isUpdating ? _controller.stopUpdates : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isUpdating ? null : _resetData,
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
      );
    });
  }

  Widget _buildVolumeButton(int volume) {
    final isSelected = _selectedVolume == volume;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedVolume = volume;
        });
        _controller.initialize(volume);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildSensorInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(8),
      color: Colors.orange[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Total Sensors: ${_controller.sensorCount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Status: ${_controller.isUpdating.value ? "Running" : "Idle"}',
            style: TextStyle(
              color: _controller.isUpdating.value
                  ? Colors.orange
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSensorList() {
    return Obx(() {
      if (_controller.sensors.isEmpty) {
        return const Center(
          child: Text('No sensors loaded. Select volume and press Reset.'),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        itemCount: _controller.sensors.length,
        itemBuilder: (context, index) {
          return SensorItemWidget(sensor: _controller.sensors[index]);
        },
      );
    });
  }

  void _resetData() {
    _controller
      ..reset()
      ..initialize(_selectedVolume);
  }
}