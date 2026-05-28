import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../scanner/models/scanned_device.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';
import 'widgets/connection_banner.dart';
import 'widgets/live_data_card.dart';
import 'widgets/service_expansion_tile.dart';

class DeviceDetailScreen extends HookWidget {
  const DeviceDetailScreen({super.key, required this.device});
  final ScannedDevice device;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final bloc = context.read<DeviceBloc>();
      return () => bloc.add(const DisconnectDevice());
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceConnected || state is DeviceStreaming) {
                return IconButton(
                  icon: const Icon(Icons.bluetooth_disabled),
                  tooltip: 'Disconnect',
                  onPressed: () =>
                      context.read<DeviceBloc>().add(const DisconnectDevice()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) => Column(
          children: [
            ConnectionBanner(state: state),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DeviceState state) {
    return switch (state) {
      DeviceConnecting() => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to device…'),
            ],
          ),
        ),
      DeviceConnected(deviceId: final id, services: final services) =>
        _ServicesList(
          deviceId: id,
          services: services,
          subscribedCharacteristicId: null,
          onSubscribe: (svcId, charId) =>
              context.read<DeviceBloc>().add(
                    SubscribeCharacteristic(
                      deviceId: id,
                      serviceId: svcId,
                      characteristicId: charId,
                    ),
                  ),
          onUnsubscribe: () =>
              context.read<DeviceBloc>().add(const UnsubscribeCharacteristic()),
        ),
      DeviceStreaming(
        deviceId: final id,
        services: final services,
        subscribedCharacteristicId: final charId,
        latestValue: final value,
      ) =>
        Column(
          children: [
            LiveDataCard(
              characteristicId: charId.toString(),
              value: value,
            ),
            Expanded(
              child: _ServicesList(
                deviceId: id,
                services: services,
                subscribedCharacteristicId: charId,
                onSubscribe: (svcId, cId) =>
                    context.read<DeviceBloc>().add(
                          SubscribeCharacteristic(
                            deviceId: id,
                            serviceId: svcId,
                            characteristicId: cId,
                          ),
                        ),
                onUnsubscribe: () => context
                    .read<DeviceBloc>()
                    .add(const UnsubscribeCharacteristic()),
              ),
            ),
          ],
        ),
      DeviceDisconnected() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              const Text('Disconnected'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () =>
                    context.read<DeviceBloc>().add(ConnectDevice(device.id)),
                child: const Text('Reconnect'),
              ),
            ],
          ),
        ),
      DeviceError(message: final msg) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 56, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(msg, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context
                      .read<DeviceBloc>()
                      .add(ConnectDevice(device.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({
    required this.deviceId,
    required this.services,
    required this.subscribedCharacteristicId,
    required this.onSubscribe,
    required this.onUnsubscribe,
  });

  final String deviceId;
  final List<DiscoveredService> services;
  final Uuid? subscribedCharacteristicId;
  final void Function(Uuid svcId, Uuid charId) onSubscribe;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('No services found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      itemBuilder: (_, i) => ServiceExpansionTile(
        service: services[i],
        deviceId: deviceId,
        subscribedCharacteristicId: subscribedCharacteristicId,
        onSubscribe: onSubscribe,
        onUnsubscribe: onUnsubscribe,
      ),
    );
  }
}
