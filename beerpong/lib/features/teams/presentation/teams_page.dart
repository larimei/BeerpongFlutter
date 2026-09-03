import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../../app/widgets/entity_overview.dart';
import '../../players/application/players_controller.dart';
import '../../players/domain/player.dart';
import '../../competitions/application/competitions_controller.dart';
import '../application/teams_controller.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({
    required this.controller,
    required this.playersController,
    this.competitionsController,
    this.onOpenSettings,
    super.key,
  });

  final TeamsController controller;
  final PlayersController playersController;
  final CompetitionsController? competitionsController;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return EntityOverviewScaffold(
      title: 'Teams',
      onOpenSettings: onOpenSettings,
      body: ListenableBuilder(
        listenable: Listenable.merge([controller, playersController]),
        builder: (context, child) {
          final teams = controller.teams;
          if (teams.isEmpty) {
            return const EmptyEntityState(
              icon: Icons.groups_outlined,
              title: 'No teams yet',
              message: 'Add your first team to start building the tournament.',
            );
          }
          return EntityGrid(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final players = playersController.playersByIds(team.playerIds);
              return EntityCard(
                name: team.name,
                color: team.color,
                icon: Icons.groups_outlined,
                additionalContent: _TeamMemberSummary(players: players),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => TeamDetailsPage(
                      teamId: team.id,
                      controller: controller,
                      playersController: playersController,
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

class _TeamMemberSummary extends StatelessWidget {
  const _TeamMemberSummary({required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    if (players.isEmpty) {
      return EntityCardText(
        text: 'No players',
        fontSize: 12,
        maxLines: 1,
        style: style,
      );
    }
    if (players.length > 2) {
      return EntityCardText(
        text: '${players.length} players',
        fontSize: 12,
        maxLines: 1,
        style: style,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: players
          .map(
            (player) => Flexible(
              child: EntityCardText(
                text: player.name,
                fontSize: 12,
                maxLines: 1,
                style: style,
              ),
            ),
          )
          .toList(),
    );
  }
}
