import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

sealed class DeviceState extends Equatable {
  const DeviceState();
  @override
  List<Object?> get props => [];
}

final class DeviceDisconnected extends DeviceState {
  const DeviceDisconnected();
}

final class DeviceConnecting extends DeviceState {
  const DeviceConnecting(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}

final class DeviceConnected extends DeviceState {
  const DeviceConnected({
    required this.deviceId,
    required this.services,
  });
  final String deviceId;
  final List<DiscoveredService> services;
  @override
  List<Object?> get props => [deviceId, services];
}

final class DeviceStreaming extends DeviceState {
  const DeviceStreaming({
    required this.deviceId,
    required this.services,
    required this.subscribedCharacteristicId,
    required this.latestValue,
  });
  final String deviceId;
  final List<DiscoveredService> services;
  final Uuid subscribedCharacteristicId;
  final List<int> latestValue;
  @override
  List<Object?> get props => [
        deviceId,
        services,
        subscribedCharacteristicId,
        latestValue,
      ];
}

final class DeviceError extends DeviceState {
  const DeviceError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
