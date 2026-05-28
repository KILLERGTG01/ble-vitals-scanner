import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleRepository {
  BleRepository() : _ble = FlutterReactiveBle();

  final FlutterReactiveBle _ble;

  Stream<BleStatus> get statusStream => _ble.statusStream;

  Stream<DiscoveredDevice> scanForDevices({List<Uuid>? withServices}) {
    return _ble.scanForDevices(
      withServices: withServices ?? [],
      scanMode: ScanMode.lowLatency,
    );
  }

  Stream<ConnectionStateUpdate> connectToDevice(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    );
  }

  Future<List<DiscoveredService>> discoverServices(String deviceId) {
    return _ble.discoverServices(deviceId);
  }

  Stream<List<int>> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: characteristicId,
      deviceId: deviceId,
    );
    return _ble.subscribeToCharacteristic(characteristic);
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: characteristicId,
      deviceId: deviceId,
    );
    return _ble.readCharacteristic(characteristic);
  }
}
