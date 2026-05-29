# BLE Scanner

A Flutter app that discovers nearby BLE devices, connects to a selected device, and displays its live data stream.

## Requirements

- Flutter 3.24+ / Dart 3.4+
- Android 10+ (API 29) device or emulator with BLE support
- For iOS: Xcode 15+, physical device (BLE unavailable on simulator)

## Setup

```bash
git clone <repo>
cd ble_scanner
flutter pub get
flutter run
```

For release APK:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Permissions

The app requests at runtime:

| Android Version | Permissions |
|---|---|
| < 12 (API < 31) | `ACCESS_FINE_LOCATION` |
| 12+ (API 31+) | `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` |

## Using flutter_reactive_ble

All BLE operations go through `BleRepository` which wraps `FlutterReactiveBle`:

```dart
// Scanning
repository.scanForDevices()            // Stream<DiscoveredDevice>

// Connecting
repository.connectToDevice(id)         // Stream<ConnectionStateUpdate>

// Discovering services
repository.discoverServices(id)        // Future<List<DiscoveredService>>

// Subscribing to a characteristic
repository.subscribeToCharacteristic(
  deviceId: id,
  serviceId: serviceUuid,
  characteristicId: charUuid,
)                                      // Stream<List<int>>
```

`FlutterReactiveBle` does not expose a disconnect method directly — you cancel the connection stream subscription, and the library handles teardown.

## Screenshots

| | | | | |
|---|---|---|---|---|
| ![Screen 1](screenshots/1.jpeg) | ![Screen 2](screenshots/2.jpeg) | ![Screen 3](screenshots/3.jpeg) | ![Screen 4](screenshots/4.jpeg) | ![Screen 5](screenshots/5.jpeg) |
