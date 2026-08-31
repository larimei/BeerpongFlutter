import 'package:flutter/material.dart';

import '../../../app/widgets/entity_details_content.dart';
import '../../../app/widgets/entity_edit_dialog.dart';
import '../application/players_controller.dart';
import '../domain/player.dart';

class PlayerDetailsPage extends StatelessWidget {
  const PlayerDetailsPage({
    required this.playerId,
    required this.controller,
    super.key,
  });

  final String playerId;
  final PlayersController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final player = controller.playerById(playerId);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: player?.color ?? const Color(0xFFF0FAF9),
            title: const Text('Player details'),
          ),
          body: player == null
              ? const Center(child: Text('Player no longer exists'))
              : Container(
                  key: const Key('player-details-background'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [player.color, Colors.white],
                    ),
                  ),
                  child: EntityDetailsContent(
                    name: player.name,
                    color: player.color,
                    icon: Icons.sports_bar_outlined,
                    won: player.won,
                    lost: player.lost,
                    entityName: 'player',
                    surfaceKey: const Key('player-details-surface'),
                    avatarKey: const Key('player-avatar'),
                    iconKey: const Key('player-details-icon'),
                    onEdit: () => _editPlayer(context, player),
                    onDelete: () => _deletePlayer(context, player),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _editPlayer(BuildContext context, Player player) async {
    final edits = await showDialog<EntityEdits>(
      context: context,
      builder: (context) => EntityEditDialog(
        entityName: 'player',
        initialName: player.name,
        initialColor: player.color,
        icon: Icons.sports_bar_outlined,
        colorPickerIconKey: const Key('color-picker-player-icon'),
        colorPickerWheelKey: const Key('player-color-wheel'),
      ),
    );
    if (edits == null) return;
    controller.updatePlayer(
      id: player.id,
      name: edits.name,
      color: edits.color,
    );
  }

  Future<void> _deletePlayer(BuildContext context, Player player) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete player?'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!(shouldDelete ?? false) || !context.mounted) return;
    controller.deletePlayer(player.id);
    Navigator.pop(context);
  }
}
