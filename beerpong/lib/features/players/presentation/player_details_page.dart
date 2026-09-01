import 'package:flutter/material.dart';

import '../../../app/widgets/entity_details_content.dart';
import '../../../app/widgets/entity_delete_dialog.dart';
import '../../../app/widgets/entity_edit_dialog.dart';
import '../../competitions/application/competitions_controller.dart';
import '../application/players_controller.dart';
import '../domain/player.dart';

class PlayerDetailsPage extends StatelessWidget {
  const PlayerDetailsPage({
    required this.playerId,
    required this.controller,
    this.competitionsController,
    super.key,
  });

  final String playerId;
  final PlayersController controller;
  final CompetitionsController? competitionsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        ?competitionsController,
      ]),
      builder: (context, child) {
        final player = controller.playerById(playerId);
        final statistics = player == null || competitionsController == null
            ? null
            : competitionsController!.statistics.forPlayer(player.id);
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
                    won: statistics?.won ?? 0,
                    lost: statistics?.lost ?? 0,
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
    final shouldDelete = await showEntityDeleteDialog(
      context,
      entityName: 'player',
      displayName: player.name,
      assignmentCount: controller.teamCountForPlayer(player.id),
      assignmentSingular: 'team',
      assignmentPlural: 'teams',
    );
    if (!shouldDelete || !context.mounted) return;
    controller.deletePlayer(player.id);
    Navigator.pop(context);
  }
}
