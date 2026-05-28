# Decisions

## BLE Library: flutter_reactive_ble only

`flutter_reactive_ble` uses a reactive stream API that maps naturally to BLoC — scan produces `Stream<DiscoveredDevice>`, connection produces `Stream<ConnectionStateUpdate>`, characteristic subscribe produces `Stream<List<int>>`. All BLE ops are wrapped in `BleRepository` to decouple features from the library.

## HookWidget everywhere

Eliminates `StatefulWidget` boilerplate. `useEffect` handles subscriptions and side effects (including screen-level cleanup like disconnect on pop), `useMemoized` handles expensive object creation (GoRouter), and `useAnimationController` removes all manual controller disposal.

## BLoC over Riverpod/Provider

BLoC's explicit event→state contract makes the async BLE state machine easy to trace. Connecting, discovering, streaming, and error states are all distinct typed classes — impossible to confuse with each other.

## Single BleRepository singleton

`FlutterReactiveBle` internally manages a BLE adapter connection. Creating multiple instances causes undefined behavior. One repository instance is provided at the root via `RepositoryProvider` and injected into each BLoC at route creation time.

## part/part of for private BLoC events

Internal events (`_DeviceDiscovered`, `_ConnectionStateUpdated`, etc.) use Dart's `_` prefix to prevent external code from dispatching them. Because `_`-prefixed names are library-private and sealed class subclasses must be in the same library, both the event and bloc files use `part`/`part of` to form a single Dart library.

## Service discovery after connected event

`flutter_reactive_ble` requires `DeviceConnectionState.connected` before `discoverServices` is safe to call. `DeviceBloc._onConnectionStateUpdated` waits for this state before issuing discovery. A post-await state guard (`if (state is DeviceDisconnected) return`) prevents phantom reconnection if the device drops while discovery is in flight.

## Disconnection via stream cancellation

`flutter_reactive_ble` has no explicit disconnect method. Cancelling the `connectToDevice` stream subscription triggers BLE disconnection. `DeviceBloc` cancels `_connectionSubscription` in `_onDisconnect` and `close()`.

## Android minSdk 21

`flutter_reactive_ble` hard-requires API 21. The app targets Android 10+ but minSdk is 21 to satisfy the library constraint.

## Issue: Permission handling differs by Android API level

Android 12+ needs `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT`; earlier versions need `ACCESS_FINE_LOCATION`. `permission_handler` handles the runtime request but all three permissions must be declared in the manifest — the OS ignores unknown permissions on older API levels.

## Issue: go_router extra type erasure

`state.extra` is typed as `Object?`, requiring a cast (`state.extra! as ScannedDevice`) at the route boundary. This is safe because only our push call sets the extra value.
