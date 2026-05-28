import 'package:equatable/equatable.dart';
import '../models/scanned_device.dart';

sealed class ScannerState extends Equatable {
  const ScannerState();
  @override
  List<Object?> get props => [];
}

final class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

final class ScannerScanning extends ScannerState {
  const ScannerScanning({required this.devices});
  final List<ScannedDevice> devices;
  @override
  List<Object?> get props => [devices];
}

final class ScannerIdle extends ScannerState {
  const ScannerIdle({required this.devices});
  final List<ScannedDevice> devices;
  @override
  List<Object?> get props => [devices];
}

final class ScannerError extends ScannerState {
  const ScannerError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
