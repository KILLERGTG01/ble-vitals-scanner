import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../../core/ble/ble_repository.dart';
import 'device_state.dart';

part 'device_bloc.dart';

sealed class DeviceEvent extends Equatable {
  const DeviceEvent();
  @override
  List<Object?> get props => [];
}

final class ConnectDevice extends DeviceEvent {
  const ConnectDevice(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}

final class DisconnectDevice extends DeviceEvent {
  const DisconnectDevice();
}

final class SubscribeCharacteristic extends DeviceEvent {
  const SubscribeCharacteristic({
    required this.deviceId,
    required this.serviceId,
    required this.characteristicId,
  });
  final String deviceId;
  final Uuid serviceId;
  final Uuid characteristicId;
  @override
  List<Object?> get props => [serviceId, characteristicId];
}

final class UnsubscribeCharacteristic extends DeviceEvent {
  const UnsubscribeCharacteristic();
}

final class _ConnectionStateUpdated extends DeviceEvent {
  const _ConnectionStateUpdated(this.update);
  final ConnectionStateUpdate update;
  @override
  List<Object?> get props => [update.connectionState];
}

final class _CharacteristicValueReceived extends DeviceEvent {
  const _CharacteristicValueReceived(this.value);
  final List<int> value;
  @override
  List<Object?> get props => [value];
}

final class _DeviceError extends DeviceEvent {
  const _DeviceError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
