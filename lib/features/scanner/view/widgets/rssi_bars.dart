import 'package:flutter/material.dart';

class RssiBars extends StatelessWidget {
  const RssiBars({super.key, required this.rssi});
  final int rssi;

  int get _bars {
    if (rssi >= -50) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  Color _barColor(BuildContext context) {
    if (rssi >= -65) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final active = _bars;
    final color = _barColor(context);
    final dim = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final height = 6.0 + i * 4.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 5,
            height: height,
            decoration: BoxDecoration(
              color: i < active ? color : dim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
