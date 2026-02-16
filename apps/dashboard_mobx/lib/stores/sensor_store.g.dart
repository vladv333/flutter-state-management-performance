// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SensorStore on _SensorStore, Store {
  Computed<int>? _$sensorCountComputed;

  @override
  int get sensorCount => (_$sensorCountComputed ??= Computed<int>(
    () => super.sensorCount,
    name: '_SensorStore.sensorCount',
  )).value;

  late final _$sensorsAtom = Atom(
    name: '_SensorStore.sensors',
    context: context,
  );

  @override
  ObservableList<SensorData> get sensors {
    _$sensorsAtom.reportRead();
    return super.sensors;
  }

  @override
  set sensors(ObservableList<SensorData> value) {
    _$sensorsAtom.reportWrite(value, super.sensors, () {
      super.sensors = value;
    });
  }

  late final _$isUpdatingAtom = Atom(
    name: '_SensorStore.isUpdating',
    context: context,
  );

  @override
  bool get isUpdating {
    _$isUpdatingAtom.reportRead();
    return super.isUpdating;
  }

  @override
  set isUpdating(bool value) {
    _$isUpdatingAtom.reportWrite(value, super.isUpdating, () {
      super.isUpdating = value;
    });
  }

  late final _$_SensorStoreActionController = ActionController(
    name: '_SensorStore',
    context: context,
  );

  @override
  void initialize(int count) {
    final _$actionInfo = _$_SensorStoreActionController.startAction(
      name: '_SensorStore.initialize',
    );
    try {
      return super.initialize(count);
    } finally {
      _$_SensorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startUpdates() {
    final _$actionInfo = _$_SensorStoreActionController.startAction(
      name: '_SensorStore.startUpdates',
    );
    try {
      return super.startUpdates();
    } finally {
      _$_SensorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void stopUpdates() {
    final _$actionInfo = _$_SensorStoreActionController.startAction(
      name: '_SensorStore.stopUpdates',
    );
    try {
      return super.stopUpdates();
    } finally {
      _$_SensorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateAllSensors() {
    final _$actionInfo = _$_SensorStoreActionController.startAction(
      name: '_SensorStore._updateAllSensors',
    );
    try {
      return super._updateAllSensors();
    } finally {
      _$_SensorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_SensorStoreActionController.startAction(
      name: '_SensorStore.reset',
    );
    try {
      return super.reset();
    } finally {
      _$_SensorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sensors: ${sensors},
isUpdating: ${isUpdating},
sensorCount: ${sensorCount}
    ''';
  }
}
