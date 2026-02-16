import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adaptive_sensor_bloc.dart';
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
      context.read<AdaptiveSensorBloc>().add(InitializeSensorsEvent(_selectedVolume));
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
        title: const Text('Adaptive BLoC Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          BlocBuilder<AdaptiveSensorBloc, SensorState>(
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
      body: BlocBuilder<AdaptiveSensorBloc, SensorState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildControlPanel(state),
              _buildStrategyInfo(state), // ⭐ НОВЫЙ виджет!
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
                onPressed: state.isUpdating
                    ? null
                    : () => context
                    .read<AdaptiveSensorBloc>()
                    .add(const StartUpdatesEvent()),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: state.isUpdating
                    ? () => context
                    .read<AdaptiveSensorBloc>()
                    .add(const StopUpdatesEvent())
                    : null,
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
        setState(() => _selectedVolume = volume);
        context
            .read<AdaptiveSensorBloc>()
            .add(InitializeSensorsEvent(volume));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text('${volume ~/ 1000}K'),
    );
  }

  Widget _buildStrategyInfo(SensorState state) {
    final strategyName = state.strategy == UpdateStrategy.normal
        ? 'NORMAL'
        : 'LIGHTWEIGHT';
    final strategyColor = state.strategy == UpdateStrategy.normal
        ? Colors.blue
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(8),
      color: strategyColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(
                state.strategy == UpdateStrategy.normal
                    ? Icons.flash_on
                    : Icons.eco,
                color: strategyColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Strategy: $strategyName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: strategyColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            'Switches: ${state.switchCount}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorInfo(SensorState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.deepPurple[50],
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
              color: state.isUpdating ? Colors.deepPurple : Colors.grey,
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

  void _resetData() {
    context.read<AdaptiveSensorBloc>()
      ..add(const ResetSensorsEvent())
      ..add(InitializeSensorsEvent(_selectedVolume));
  }
}