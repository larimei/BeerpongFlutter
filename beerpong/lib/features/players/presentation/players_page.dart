import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../../app/widgets/entity_overview.dart';
import '../../competitions/application/competitions_controller.dart';
import '../application/players_controller.dart';
import 'player_details_page.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({
    required this.controller,
    this.competitionsController,
    this.onOpenSettings,
    super.key,
  });

  final PlayersController controller;
  final CompetitionsController? competitionsController;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return EntityOverviewScaffold(
      title: 'Players',
      onOpenSettings: onOpenSettings,
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final players = controller.players;
          if (players.isEmpty) {
            return const EmptyEntityState(
              icon: Icons.sports_bar_outlined,
              title: 'No players yet',
              message:
                  'Add your first player to start building the tournament.',
            );
          }
          return EntityGrid(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return EntityCard(
                name: player.name,
                color: player.color,
                icon: Icons.sports_bar_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PlayerDetailsPage(
                      playerId: player.id,
                      controller: controller,
                      competitionsController: competitionsController,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
