import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class CharacteristicRow extends StatelessWidget {
  const CharacteristicRow({
    super.key,
    required this.characteristic,
    required this.isSubscribed,
    required this.onSubscribe,
    required this.onUnsubscribe,
  });

  final DiscoveredCharacteristic characteristic;
  final bool isSubscribed;
  final VoidCallback onSubscribe;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canNotify =
        characteristic.isNotifiable || characteristic.isIndicatable;
    final props = [
      if (characteristic.isReadable) 'READ',
      if (characteristic.isWritableWithResponse) 'WRITE',
      if (characteristic.isWritableWithoutResponse) 'WRITE-NR',
      if (characteristic.isNotifiable) 'NOTIFY',
      if (characteristic.isIndicatable) 'INDICATE',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  characteristic.characteristicId.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                if (props.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: props
                        .map(
                          (p) => Chip(
                            label: Text(p),
                            labelStyle: theme.textTheme.labelSmall,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (canNotify)
            isSubscribed
                ? FilledButton.tonal(
                    onPressed: onUnsubscribe,
                    child: const Text('Unsubscribe'),
                  )
                : OutlinedButton(
                    onPressed: onSubscribe,
                    child: const Text('Subscribe'),
                  ),
        ],
      ),
    );
  }
}
