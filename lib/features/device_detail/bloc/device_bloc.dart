part of 'device_event.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc({required BleRepository repository})
      : _repository = repository,
        super(const DeviceDisconnected()) {
    on<ConnectDevice>(_onConnect);
    on<DisconnectDevice>(_onDisconnect);
    on<SubscribeCharacteristic>(_onSubscribe);
    on<UnsubscribeCharacteristic>(_onUnsubscribe);
    on<_ConnectionStateUpdated>(_onConnectionStateUpdated);
    on<_CharacteristicValueReceived>(_onValueReceived);
    on<_DeviceError>(_onError);
  }

  final BleRepository _repository;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  Future<void> _onConnect(
    ConnectDevice event,
    Emitter<DeviceState> emit,
  ) async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    emit(DeviceConnecting(event.deviceId));
    _connectionSubscription = _repository
        .connectToDevice(event.deviceId)
        .listen(
          (update) => add(_ConnectionStateUpdated(update)),
          onError: (Object e) => add(_DeviceError(e.toString())),
        );
  }

  Future<void> _onDisconnect(
    DisconnectDevice event,
    Emitter<DeviceState> emit,
  ) async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    emit(const DeviceDisconnected());
  }

  Future<void> _onConnectionStateUpdated(
    _ConnectionStateUpdated event,
    Emitter<DeviceState> emit,
  ) async {
    switch (event.update.connectionState) {
      case DeviceConnectionState.connected:
        final deviceId = switch (state) {
          DeviceConnecting(deviceId: final id) => id,
          _ => event.update.deviceId,
        };
        try {
          final services = await _repository.discoverServices(deviceId);
          if (state is DeviceDisconnected) return;
          emit(DeviceConnected(deviceId: deviceId, services: services));
        } catch (e) {
          emit(DeviceError(e.toString()));
        }

      case DeviceConnectionState.disconnected:
        await _characteristicSubscription?.cancel();
        _characteristicSubscription = null;
        if (state is! DeviceDisconnected) emit(const DeviceDisconnected());

      case DeviceConnectionState.connecting:
      case DeviceConnectionState.disconnecting:
        break;
    }
  }

  Future<void> _onSubscribe(
    SubscribeCharacteristic event,
    Emitter<DeviceState> emit,
  ) async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    final services = switch (state) {
      DeviceConnected(services: final s) => s,
      DeviceStreaming(services: final s) => s,
      _ => <DiscoveredService>[],
    };
    emit(DeviceStreaming(
      deviceId: event.deviceId,
      services: services,
      subscribedCharacteristicId: event.characteristicId,
      latestValue: const [],
    ));
    _characteristicSubscription = _repository
        .subscribeToCharacteristic(
          deviceId: event.deviceId,
          serviceId: event.serviceId,
          characteristicId: event.characteristicId,
        )
        .listen(
          (value) => add(_CharacteristicValueReceived(value)),
          onError: (Object e) => add(_DeviceError(e.toString())),
        );
  }

  Future<void> _onUnsubscribe(
    UnsubscribeCharacteristic event,
    Emitter<DeviceState> emit,
  ) async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    if (state case DeviceStreaming(
      deviceId: final id,
      services: final s,
    )) {
      emit(DeviceConnected(deviceId: id, services: s));
    }
  }

  void _onValueReceived(
    _CharacteristicValueReceived event,
    Emitter<DeviceState> emit,
  ) {
    if (state case DeviceStreaming(
      deviceId: final id,
      services: final s,
      subscribedCharacteristicId: final charId,
    )) {
      emit(DeviceStreaming(
        deviceId: id,
        services: s,
        subscribedCharacteristicId: charId,
        latestValue: event.value,
      ));
    }
  }

  void _onError(_DeviceError event, Emitter<DeviceState> emit) {
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    emit(DeviceError(event.message));
  }

  @override
  Future<void> close() async {
    await _characteristicSubscription?.cancel();
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
