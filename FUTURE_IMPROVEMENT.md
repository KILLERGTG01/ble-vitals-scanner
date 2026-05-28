# Future Improvements

## Production Readiness

**Connection retry with backoff.** Currently the app shows a manual retry button on failure. Production apps should implement exponential backoff (e.g., 1s, 2s, 4s, max 30s) with a max attempt count, surfacing permanent failure only after exhaustion.

**MTU negotiation.** Call `requestMtu(deviceId, 512)` after the connected event for devices that support larger payloads. Required for characteristics returning sensor packets > 20 bytes.

**Background scanning.** Use a foreground service (Android) or background mode (iOS) to continue scanning/streaming when backgrounded. Requires `flutter_background_service` or native platform channels.

**State persistence.** Persist known devices to `SharedPreferences` or SQLite so the scanner can show previously seen devices immediately on reopen.

**Bluetooth state gate.** Check `BleRepository.statusStream` on launch and show a "Bluetooth is off" card instead of silently failing to scan. `BleStatus.ready` is the only state where scanning works.

## Scaling

**BLoC unit tests.** Use `bloc_test` to unit-test every ScannerBloc and DeviceBloc state transition. The deduplication logic, double-`StartScan` re-scan, and post-await disconnect race are the highest-value test targets.

**Device profile registry.** A UUID → decoder map would allow `LiveDataCard` to show "Heart Rate: 72 bpm" instead of raw bytes for standard BLE profiles (Heart Rate, Battery, Environmental Sensing).

**Analytics + crash reporting.** Add `firebase_analytics` and `firebase_crashlytics`. BLE connection failures are the most common user-facing error — per-device-model failure rates are essential for debugging field issues.

**CI/CD pipeline.** Add a GitHub Actions workflow: `flutter analyze`, `flutter test`, and `flutter build apk --release` on every PR. Upload the APK artifact for manual QA.

**Repository abstraction for testability.** Extract a `BleRepositoryInterface` (abstract class or interface) so `BleRepository` can be mocked in BLoC tests without touching `FlutterReactiveBle`.
