import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../features/scanner/models/scanned_device.dart';

class DeviceDetailScreen extends HookWidget {
  const DeviceDetailScreen({super.key, required this.device});
  final ScannedDevice device;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(device.name)),
        body: const Center(child: Text('Device Detail')),
      );
}
