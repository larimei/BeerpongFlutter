import 'package:flutter/material.dart';

class StatisticBar extends StatelessWidget {
  const StatisticBar({required this.wins, required this.losses, super.key});

  final int wins;
  final int losses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Wins', style: Theme.of(context).textTheme.titleSmall),
            Text('Losses', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 32,
            child: Row(
              children: [
                Expanded(
                  flex: wins == 0 ? 1 : wins,
                  child: _StatisticSegment(
                    value: wins,
                    color: Colors.amber.shade600,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Expanded(
                  flex: losses == 0 ? 1 : losses,
                  child: _StatisticSegment(
                    value: losses,
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticSegment extends StatelessWidget {
  const _StatisticSegment({
    required this.value,
    required this.color,
    required this.alignment,
  });

  final int value;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Text(
      '$value',
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
