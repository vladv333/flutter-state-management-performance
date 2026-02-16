import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final MockDataService _dataService = MockDataService();
  Timer? _updateTimer;

  SensorBloc() : super(const SensorInitial()) {
    on<InitializeSensorsEvent>(_onInitialize);
    on<StartUpdatesEvent>(_onStartUpdates);
    on<StopUpdatesEvent>(_onStopUpdates);
    on<UpdateSensorsEvent>(_onUpdateSensors);
    on<ResetSensorsEvent>(_onReset);
  }

  void _onInitialize(
      InitializeSensorsEvent event,
      Emitter<SensorState> emit,
      ) {
    final sensors = _dataService.generateSensors(event.count);
    emit(SensorLoaded(sensors: sensors, isUpdating: false));
  }

  void _onStartUpdates(
      StartUpdatesEvent event,
      Emitter<SensorState> emit,
      ) {
    if (state is! SensorLoaded) return;
    if (state.isUpdating) return;

    final currentState = state as SensorLoaded;
    emit(currentState.copyWith(isUpdating: true));

    // Таймер обновлений каждые 100ms
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        add(const UpdateSensorsEvent());
      },
    );
  }

  void _onStopUpdates(
      StopUpdatesEvent event,
      Emitter<SensorState> emit,
      ) {
    _updateTimer?.cancel();
    _updateTimer = null;

    if (state is SensorLoaded) {
      final currentState = state as SensorLoaded;
      emit(currentState.copyWith(isUpdating: false));
    }
  }

  void _onUpdateSensors(
      UpdateSensorsEvent event,
      Emitter<SensorState> emit,
      ) {
    if (state is! SensorLoaded) return;

    final currentState = state as SensorLoaded;
    final updatedSensors = currentState.sensors.map((sensor) {
      return _dataService.updateSensor(sensor);
    }).toList();

    emit(currentState.copyWith(sensors: updatedSensors));
  }

  void _onReset(
      ResetSensorsEvent event,
      Emitter<SensorState> emit,
      ) {
    _updateTimer?.cancel();
    _updateTimer = null;
    emit(const SensorInitial());
  }

  @override
  Future<void> close() {
    _updateTimer?.cancel();
    return super.close();
  }
}