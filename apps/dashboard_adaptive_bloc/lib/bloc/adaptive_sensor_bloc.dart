import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';
import '../models/sensor_data.dart';
import '../services/mock_data_service.dart';

class AdaptiveSensorBloc extends Bloc<SensorEvent, SensorState> {
  final MockDataService _dataService = MockDataService();
  Timer? _updateTimer;

  // Adaptive logic variables
  final List<int> _recentFrameTimes = [];
  int _consecutiveJankFrames = 0;
  int _consecutiveGoodFrames = 0;
  UpdateStrategy _currentStrategy = UpdateStrategy.normal;
  int _switchCount = 0;

  // Thresholds
  static const int _jankThreshold = 3;
  static const int _goodFramesThreshold = 10;
  static const int _targetFrameTimeMs = 17;

  AdaptiveSensorBloc() : super(const SensorInitial()) {
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
    emit(SensorLoaded(
      sensors: sensors,
      isUpdating: false,
      strategy: UpdateStrategy.normal,
      switchCount: 0,
    ));

    _currentStrategy = UpdateStrategy.normal;
    _switchCount = 0;
    _consecutiveJankFrames = 0;
    _consecutiveGoodFrames = 0;
    _recentFrameTimes.clear();

    print('INITIALIZED: ${event.count} sensors');
  }

  void _onStartUpdates(
      StartUpdatesEvent event,
      Emitter<SensorState> emit,
      ) {
    if (state is! SensorLoaded) {
      print('Cannot start: state is not SensorLoaded');
      return;
    }

    if (state.isUpdating) {
      print('Already updating, ignoring Start');
      return;
    }

    final currentState = state as SensorLoaded;
    emit(currentState.copyWith(isUpdating: true));

    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        if (state is SensorLoaded && state.isUpdating) {
          add(const UpdateSensorsEvent());
        } else {
          timer.cancel();
          print('Timer auto-cancelled: state changed');
        }
      },
    );

    print('START: Timer started, isUpdating = true');
  }

  void _onStopUpdates(
      StopUpdatesEvent event,
      Emitter<SensorState> emit,
      ) {
    print('STOP called');
    if (_updateTimer != null) {
      _updateTimer!.cancel();
      _updateTimer = null;
      print('Timer cancelled successfully');
    } else {
      print('Timer was already null');
    }

    if (state is SensorLoaded) {
      final currentState = state as SensorLoaded;
      emit(currentState.copyWith(isUpdating: false));
      print('State updated: isUpdating = false');
    } else {
      print('State is not SensorLoaded!');
    }
  }

  void _onUpdateSensors(
      UpdateSensorsEvent event,
      Emitter<SensorState> emit,
      ) {
    if (state is! SensorLoaded) return;

    final currentState = state as SensorLoaded;
    if (!currentState.isUpdating) {
      print('Update event received but isUpdating=false, ignoring');
      return;
    }

    final startTime = DateTime.now();

    final updatedSensors = _updateSensorsWithStrategy(currentState.sensors);

    final frameTime = DateTime.now().difference(startTime).inMilliseconds;

    final newStrategy = _analyzePerformance(frameTime);

    emit(currentState.copyWith(
      sensors: updatedSensors,
      strategy: newStrategy,
      switchCount: _switchCount,
    ));
  }

  List<SensorData> _updateSensorsWithStrategy(List<SensorData> sensors) {
    switch (_currentStrategy) {
      case UpdateStrategy.normal:
        return sensors.map((sensor) {
          return _dataService.updateSensor(sensor);
        }).toList();

      case UpdateStrategy.lightweight:
        final updated = List<SensorData>.from(sensors);
        for (int i = 0; i < updated.length; i++) {
          if (i < 20 || i % 5 == 0) {
            updated[i] = _dataService.updateSensor(updated[i]);
          }
        }
        return updated;
    }
  }

  UpdateStrategy _analyzePerformance(int frameTimeMs) {
    _recentFrameTimes.add(frameTimeMs);
    if (_recentFrameTimes.length > 5) {
      _recentFrameTimes.removeAt(0);
    }

    final isJank = frameTimeMs > _targetFrameTimeMs;

    if (isJank) {
      _consecutiveJankFrames++;
      _consecutiveGoodFrames = 0;
    } else {
      _consecutiveGoodFrames++;
      _consecutiveJankFrames = 0;
    }

    if (_currentStrategy == UpdateStrategy.normal &&
        _consecutiveJankFrames >= _jankThreshold) {
      _currentStrategy = UpdateStrategy.lightweight;
      _switchCount++;
      _consecutiveJankFrames = 0;
      print('SWITCHED TO LIGHTWEIGHT (Switch #$_switchCount)');
    }
    else if (_currentStrategy == UpdateStrategy.lightweight &&
        _consecutiveGoodFrames >= _goodFramesThreshold) {
      _currentStrategy = UpdateStrategy.normal;
      _switchCount++;
      _consecutiveGoodFrames = 0;
      print('SWITCHED TO NORMAL (Switch #$_switchCount)');
    }

    return _currentStrategy;
  }

  void _onReset(
      ResetSensorsEvent event,
      Emitter<SensorState> emit,
      ) {
    print('RESET called');

    _updateTimer?.cancel();
    _updateTimer = null;
    _currentStrategy = UpdateStrategy.normal;
    _switchCount = 0;
    _consecutiveJankFrames = 0;
    _consecutiveGoodFrames = 0;
    _recentFrameTimes.clear();

    emit(const SensorInitial());

    print('   Reset complete');
  }

  @override
  Future<void> close() {
    print('CLOSING BLoC');
    _updateTimer?.cancel();
    return super.close();
  }
}