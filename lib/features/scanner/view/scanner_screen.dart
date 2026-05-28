import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/permissions/permission_service.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../models/scanned_device.dart';
import 'widgets/device_tile.dart';
import 'widgets/scan_fab.dart';

class ScannerScreen extends HookWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();

    useEffect(() {
      _initPermissionsAndScan(context, permissionService);
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        actions: [
          BlocBuilder<ScannerBloc, ScannerState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear devices',
              onPressed: state is ScannerIdle
                  ? () => context.read<ScannerBloc>().add(const ClearDevices())
                  : null,
            ),
          ),
        ],
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scan error: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          ScannerInitial() => const _PermissionPrompt(),
          ScannerScanning(devices: final devices) => devices.isEmpty
              ? const _EmptyScanView()
              : _DeviceList(devices: devices),
          ScannerIdle(devices: final devices) => devices.isEmpty
              ? const _IdleEmptyView()
              : _DeviceList(devices: devices),
          ScannerError() => _ErrorView(message: state.message),
        },
      ),
      floatingActionButton: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) => ScanFab(
          isScanning: state is ScannerScanning,
          onToggle: () {
            if (state is ScannerScanning) {
              context.read<ScannerBloc>().add(const StopScan());
            } else {
              _initPermissionsAndScan(context, permissionService);
            }
          },
        ),
      ),
    );
  }

  Future<void> _initPermissionsAndScan(
    BuildContext context,
    PermissionService permissionService,
  ) async {
    final granted = await permissionService.requestBlePermissions();
    if (!context.mounted) return;
    if (granted) {
      context.read<ScannerBloc>().add(const StartScan());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Bluetooth permissions required to scan for devices.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: permissionService.openSettings,
          ),
        ),
      );
    }
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.devices});
  final List<ScannedDevice> devices;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceTile(
          device: device,
          onTap: () => context.push('/device/${device.id}', extra: device),
        );
      },
    );
  }
}

class _EmptyScanView extends StatelessWidget {
  const _EmptyScanView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text('Searching for BLE devices…'),
        ],
      ),
    );
  }
}

class _IdleEmptyView extends StatelessWidget {
  const _IdleEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          const Text('No devices found. Tap Start Scan.'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bluetooth Permission',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant Bluetooth and Location permissions to scan for nearby BLE devices.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
