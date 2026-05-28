import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'characteristic_row.dart';

class ServiceExpansionTile extends StatelessWidget {
  const ServiceExpansionTile({
    super.key,
    required this.service,
    required this.deviceId,
    required this.subscribedCharacteristicId,
    required this.onSubscribe,
    required this.onUnsubscribe,
  });

  final DiscoveredService service;
  final String deviceId;
  final Uuid? subscribedCharacteristicId;
  final void Function(Uuid serviceId, Uuid characteristicId) onSubscribe;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          service.serviceId.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${service.characteristics.length} characteristic${service.characteristics.length == 1 ? '' : 's'}',
          style: theme.textTheme.labelSmall,
        ),
        leading: Icon(
          Icons.settings_input_component_outlined,
          color: theme.colorScheme.primary,
        ),
        children: service.characteristics.map((char) {
          final isSubscribed =
              subscribedCharacteristicId == char.characteristicId;
          return CharacteristicRow(
            characteristic: char,
            isSubscribed: isSubscribed,
            onSubscribe: () =>
                onSubscribe(service.serviceId, char.characteristicId),
            onUnsubscribe: onUnsubscribe,
          );
        }).toList(),
      ),
    );
  }
}
