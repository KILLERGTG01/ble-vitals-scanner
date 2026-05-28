import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../../core/ble/ble_repository.dart';
import '../models/scanned_device.dart';
import 'scanner_state.dart';

part 'scanner_bloc.dart';

sealed class ScannerEvent extends Equatable {
  const ScannerEvent();
  @override
  List<Object?> get props => [];
}

final class StartScan extends ScannerEvent {
  const StartScan();
}

final class StopScan extends ScannerEvent {
  const StopScan();
}

final class ClearDevices extends ScannerEvent {
  const ClearDevices();
}

final class _DeviceDiscovered extends ScannerEvent {
  const _DeviceDiscovered(this.device);
  final DiscoveredDevice device;
  @override
  List<Object?> get props => [device.id];
}

final class _ScanErrorOccurred extends ScannerEvent {
  const _ScanErrorOccurred(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
