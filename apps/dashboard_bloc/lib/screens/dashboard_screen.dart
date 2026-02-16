import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sensor_bloc.dart';
import '../bloc/sensor_event.dart';
import '../bloc/sensor_state.dart';
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
      context.read<SensorBloc>().add(InitializeSensorsEvent(_selectedVolume));
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
        title: const Text('BLoC Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          BlocBuilder<SensorBloc, SensorState>(
            builder: (context, state) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    state.isUpdating ? 'UPDATING' : 'STOPPED',
                    style: TextStyle(
                      color: state.isUpdating ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SensorBloc, SensorState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildControlPanel(state),
              _buildSensorInfo(state),
              Expanded(child: _buildSensorList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlPanel(SensorState state) {
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
                onPressed: state.isUpdating ? null : _startUpdates,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: state.isUpdating ? _stopUpdates : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: state.isUpdating ? null : _resetData,
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
        context.read<SensorBloc>().add(InitializeSensorsEvent(volume));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildSensorInfo(SensorState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.purple[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Total Sensors: ${state.sensorCount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Status: ${state.isUpdating ? "Running" : "Idle"}',
            style: TextStyle(
              color: state.isUpdating ? Colors.purple : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorList(SensorState state) {
    if (state.sensors.isEmpty) {
      return const Center(
        child: Text('No sensors loaded. Select volume and press Reset.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.sensors.length,
      itemBuilder: (context, index) {
        return SensorItemWidget(sensor: state.sensors[index]);
      },
    );
  }

  void _startUpdates() {
    context.read<SensorBloc>().add(const StartUpdatesEvent());
  }

  void _stopUpdates() {
    context.read<SensorBloc>().add(const StopUpdatesEvent());
  }

  void _resetData() {
    context.read<SensorBloc>()
      ..add(const ResetSensorsEvent())
      ..add(InitializeSensorsEvent(_selectedVolume));
  }
}