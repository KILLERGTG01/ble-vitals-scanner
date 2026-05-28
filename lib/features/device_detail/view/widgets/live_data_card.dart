import 'package:flutter/material.dart';

class LiveDataCard extends StatelessWidget {
  const LiveDataCard({
    super.key,
    required this.characteristicId,
    required this.value,
  });

  final String characteristicId;
  final List<int> value;

  String get _hex =>
      value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase();

  String get _ascii => String.fromCharCodes(
        value.where((b) => b >= 32 && b < 127),
      );

  String get _decimal => value.join(', ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Data',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${value.length} byte${value.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const Divider(height: 20),
            _DataRow(label: 'HEX', value: _hex.isEmpty ? '—' : _hex),
            _DataRow(label: 'ASCII', value: _ascii.isEmpty ? '—' : _ascii),
            _DataRow(label: 'DEC', value: _decimal.isEmpty ? '—' : _decimal),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
