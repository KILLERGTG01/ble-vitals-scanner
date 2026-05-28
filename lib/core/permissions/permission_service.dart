import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestBlePermissions() async {
    if (!Platform.isAndroid) return true;

    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    return statuses.values.every(
      (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
    );
  }

  Future<bool> get areBlePermissionsGranted async {
    if (!Platform.isAndroid) return true;
    final statuses = await Future.wait([
      Permission.location.status,
      Permission.bluetoothScan.status,
      Permission.bluetoothConnect.status,
    ]);
    return statuses.every(
      (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
    );
  }

  Future<void> openSettings() => openAppSettings();
}
