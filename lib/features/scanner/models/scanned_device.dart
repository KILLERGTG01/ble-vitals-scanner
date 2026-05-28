import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final class ScannedDevice extends Equatable {
  const ScannedDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
  });

  final String id;
  final String name;
  final int rssi;
  final List<Uuid> serviceUuids;

  factory ScannedDevice.fromDiscovered(DiscoveredDevice d) => ScannedDevice(
        id: d.id,
        name: d.name.isEmpty ? 'Unknown Device' : d.name,
        rssi: d.rssi,
        serviceUuids: d.serviceUuids,
      );

  ScannedDevice withRssi(int newRssi) => ScannedDevice(
        id: id,
        name: name,
        rssi: newRssi,
        serviceUuids: serviceUuids,
      );

  @override
  List<Object?> get props => [id, name, rssi, serviceUuids];
}
