import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ScannerScreen extends HookWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Scanner')),
      );
}
