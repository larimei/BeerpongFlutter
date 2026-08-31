import 'package:flutter/material.dart';

import '../../../players/domain/player.dart';

class PlayerSelection extends StatelessWidget {
  const PlayerSelection({
    required this.players,
    required this.selectedPlayerIds,
    required this.onChanged,
    super.key,
  });

  final List<Player> players;
  final Set<String> selectedPlayerIds;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Players', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (players.isEmpty)
          const Text('No players available. Add players first.')
        else
          ...players.map((player) {
            final selected = selectedPlayerIds.contains(player.id);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(player.name),
              trailing: IconButton(
                tooltip: selected
                    ? 'Remove ${player.name}'
                    : 'Add ${player.name}',
                onPressed: () => onChanged(player.id),
                icon: Icon(selected ? Icons.delete_outline : Icons.add),
              ),
            );
          }),
      ],
    );
  }
}
