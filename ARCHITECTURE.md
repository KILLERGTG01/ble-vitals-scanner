# Architecture

## Folder Structure

```
lib/
  core/                         # Shared infrastructure
    ble/ble_repository.dart     # Single BLE abstraction
    permissions/                # Runtime permission wrapper
    router/                     # go_router config
    theme/                      # Material 3 theme
  features/
    scanner/                    # Scan feature (self-contained)
      bloc/                     # ScannerBloc + events + states
      models/                   # ScannedDevice
      view/                     # ScannerScreen + widgets
    device_detail/              # Device detail feature
      bloc/                     # DeviceBloc + events + states
      view/                     # DeviceDetailScreen + widgets
  app.dart                      # Root HookWidget
  main.dart                     # Entry point + providers
```

## State Management

**BLoC** handles all async state. No state lives in widgets — widgets dispatch events and render states.

- `ScannerBloc`: manages `FlutterReactiveBle` scan stream subscription; deduplicates discovered devices by ID; sorts by RSSI descending.
- `DeviceBloc`: manages connection stream + characteristic subscription. One active subscription at a time — subscribing to a new characteristic cancels the previous.

## Data Flow

```
BleRepository
    ↓ Stream<DiscoveredDevice>
ScannerBloc → ScannerState → ScannerScreen → DeviceTile
                                    ↓ (tap)
                              GoRouter.push('/device/:id', extra: device)
                                    ↓
DeviceBloc → DeviceState → DeviceDetailScreen
              ↓
    ConnectionStateUpdate → discoverServices()
              ↓
    DeviceConnected(services) → ServiceExpansionTile
              ↓ (subscribe)
    Stream<List<int>> → DeviceStreaming(latestValue) → LiveDataCard
```

## HookWidget Pattern

Every widget uses `HookWidget` (from `flutter_hooks`). Side effects use `useEffect`, local UI state uses `useState`, expensive objects use `useMemoized`.

`ScanFab` uses `useAnimationController` and `useEffect` to run/stop its rotation animation based on scan state — no `AnimationController` disposal code needed.

`DeviceDetailScreen` uses `useEffect` returning a cleanup function that dispatches `DisconnectDevice` when the screen is popped.

## Navigation

`go_router` with type-safe `extra` parameter for passing `ScannedDevice` to the detail route. Each route creates its BLoC via `BlocProvider` so the BLoC lifetime is tied to the route.

## Private BLoC Events

Both `ScannerBloc` and `DeviceBloc` use internal events (`_DeviceDiscovered`, `_ConnectionStateUpdated`, etc.) that are library-private via Dart's `_` prefix. The `part`/`part of` pattern is used to place bloc and event files in the same Dart library, making private events accessible to the bloc while hiding them from the public API.

## Additional Features

- RSSI signal bars with animated color change (green/orange/red)
- Live data decoded as HEX, ASCII, and decimal
- Clear devices button when not scanning
- Reconnect and retry buttons on error/disconnect states
- Disconnect button in AppBar when connected
- Python BLE peripheral simulator for testing without hardware
