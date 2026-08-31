import 'package:flutter/material.dart';

import 'statistic_bar.dart';

class EntityDetailsContent extends StatelessWidget {
  const EntityDetailsContent({
    required this.name,
    required this.color,
    required this.icon,
    required this.won,
    required this.lost,
    required this.entityName,
    required this.onEdit,
    required this.onDelete,
    this.showStatistics = true,
    this.surfaceKey,
    this.avatarKey,
    this.iconKey,
    this.additionalContent,
    super.key,
  });

  final String name;
  final Color color;
  final IconData icon;
  final int won;
  final int lost;
  final String entityName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showStatistics;
  final Key? surfaceKey;
  final Key? avatarKey;
  final Key? iconKey;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    final totalGames = won + lost;
    final wonFraction = totalGames == 0 ? 0.0 : won / totalGames;
    final lostFraction = totalGames == 0 ? 0.0 : lost / totalGames;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Card(
                  key: surfaceKey,
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (additionalContent != null) ...[
                          const SizedBox(height: 24),
                          additionalContent!,
                        ],
                        if (showStatistics) ...[
                          const SizedBox(height: 36),
                          Text(
                            'Statistics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          StatisticBar(
                            label: 'Won games',
                            value: won,
                            fraction: wonFraction,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(height: 20),
                          StatisticBar(
                            label: 'Lost games',
                            value: lost,
                            fraction: lostFraction,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text('Edit $entityName'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: Text('Delete $entityName'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                key: avatarKey,
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, key: iconKey, size: 58, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
