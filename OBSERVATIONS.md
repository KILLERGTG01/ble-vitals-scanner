# Observations

## What I Learned

**BLE connection is a stream, not a future.** `flutter_reactive_ble` models the connection lifecycle as a stream of `ConnectionStateUpdate` events. You cannot `await connect()` — you must listen for `DeviceConnectionState.connected` before calling `discoverServices`. This forces explicit handling of every lifecycle transition.

**Post-await state guards are essential in BLoC.** Any `await` inside a BLoC event handler creates a window where another event can run and change state. After `await _repository.discoverServices(...)`, checking `if (state is DeviceDisconnected) return` prevents emitting `DeviceConnected` on a device that has already disconnected.

**RSSI is noisy.** Stationary devices show ±5 dBm variation between scan events. Sorting by RSSI descending gives a useful proximity approximation but the list reorders frequently. A smoothed exponential moving average would improve UX.

**Service discovery has latency.** After receiving `DeviceConnectionState.connected`, `discoverServices` can take 200ms–2s depending on the device and service count. A loading state during this window is necessary.

**Characteristic properties must be checked before subscribing.** Not all characteristics are notifiable. Checking `isNotifiable || isIndicatable` before showing the subscribe button prevents runtime errors from the BLE stack.

## BLE Observations

- Android BLE scan requires location permission on API < 31 — a counterintuitive OS requirement that surprises users.
- `flutter_reactive_ble` handles BLE MTU negotiation internally, but large characteristic values (>20 bytes) may be silently truncated on older devices unless MTU is explicitly requested.
- Some BLE devices stop advertising after the first connection — the scanner won't re-discover them until they explicitly start advertising again.
- `ScanMode.lowLatency` returns results ~200ms faster than `balanced` but drains battery significantly faster.
- The `part`/`part of` pattern in Dart is the correct mechanism when sealed class subclasses need to be library-private — it is not a workaround, it is the intended language feature.

## Improvements With More Time

- Smooth RSSI with exponential moving average: `newRssi = 0.3 * latest + 0.7 * previous`
- Filter by service UUID or device name in the scanner
- Read characteristic support alongside subscribe
- Show manufacturer data and service data from advertisement payload
- Write to characteristics (text + hex input)
- Connection retry with exponential backoff
- MTU negotiation after connect (`requestMtu(deviceId, 512)`)
- Persist scan results across rotations via keepAlive BLoC
