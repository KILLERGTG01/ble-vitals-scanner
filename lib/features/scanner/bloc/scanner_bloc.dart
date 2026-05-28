part of 'scanner_event.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({required BleRepository repository})
      : _repository = repository,
        super(const ScannerInitial()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ClearDevices>(_onClearDevices);
    on<_DeviceDiscovered>(_onDeviceDiscovered);
    on<_ScanErrorOccurred>(_onScanError);
  }

  final BleRepository _repository;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  List<ScannedDevice> get _currentDevices => switch (state) {
        ScannerScanning(devices: final d) => d,
        ScannerIdle(devices: final d) => d,
        _ => [],
      };

  Future<void> _onStartScan(
    StartScan event,
    Emitter<ScannerState> emit,
  ) async {
    final devices = _currentDevices;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(ScannerScanning(devices: devices));
    _scanSubscription = _repository.scanForDevices().listen(
      (device) => add(_DeviceDiscovered(device)),
      onError: (Object e) => add(_ScanErrorOccurred(e.toString())),
    );
  }

  Future<void> _onStopScan(
    StopScan event,
    Emitter<ScannerState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(ScannerIdle(devices: _currentDevices));
  }

  void _onClearDevices(ClearDevices event, Emitter<ScannerState> emit) {
    emit(ScannerIdle(devices: const []));
  }

  void _onDeviceDiscovered(
    _DeviceDiscovered event,
    Emitter<ScannerState> emit,
  ) {
    if (state is! ScannerScanning) return;
    final current = _currentDevices;
    final incoming = ScannedDevice.fromDiscovered(event.device);
    final index = current.indexWhere((d) => d.id == incoming.id);

    final updated = [...current];
    if (index == -1) {
      updated.add(incoming);
    } else {
      updated[index] = updated[index].withRssi(incoming.rssi);
    }
    updated.sort((a, b) => b.rssi.compareTo(a.rssi));
    emit(ScannerScanning(devices: updated));
  }

  void _onScanError(
    _ScanErrorOccurred event,
    Emitter<ScannerState> emit,
  ) {
    _scanSubscription = null;
    emit(ScannerError(event.message));
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    return super.close();
  }
}
