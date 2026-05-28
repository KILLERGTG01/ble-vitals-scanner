import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ScanFab extends HookWidget {
  const ScanFab({
    super.key,
    required this.isScanning,
    required this.onToggle,
  });

  final bool isScanning;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    useEffect(() {
      if (isScanning) {
        controller.repeat();
      } else {
        controller.stop();
        controller.reset();
      }
      return null;
    }, [isScanning]);

    return FloatingActionButton.extended(
      onPressed: onToggle,
      icon: AnimatedBuilder(
        animation: controller,
        builder: (_, child) => Transform.rotate(
          angle: controller.value * 6.28,
          child: child,
        ),
        child: Icon(isScanning ? Icons.radar : Icons.search),
      ),
      label: Text(isScanning ? 'Stop Scan' : 'Start Scan'),
    );
  }
}
