import 'package:flutter/material.dart';
import '../../bloc/device_state.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.state});
  final DeviceState state;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon, showSpinner) = switch (state) {
      DeviceConnecting() => (
          'Connecting…',
          Theme.of(context).colorScheme.secondaryContainer,
          Icons.bluetooth_searching,
          true,
        ),
      DeviceConnected() => (
          'Connected',
          const Color(0xFF30D158).withValues(alpha: 0.15),
          Icons.bluetooth_connected,
          false,
        ),
      DeviceStreaming() => (
          'Streaming',
          Theme.of(context).colorScheme.primaryContainer,
          Icons.graphic_eq,
          false,
        ),
      DeviceDisconnected() => (
          'Disconnected',
          Theme.of(context).colorScheme.errorContainer,
          Icons.bluetooth_disabled,
          false,
        ),
      DeviceError() => (
          'Error',
          Theme.of(context).colorScheme.errorContainer,
          Icons.error_outline,
          false,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showSpinner)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
