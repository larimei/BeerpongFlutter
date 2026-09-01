import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../players/application/players_controller.dart';
import '../../players/domain/player.dart';
import '../application/teams_controller.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({
    required this.controller,
    required this.playersController,
    this.onOpenSettings,
    super.key,
  });

  final TeamsController controller;
  final PlayersController playersController;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF9),
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([controller, playersController]),
        builder: (context, child) {
          final teams = controller.teams;
          if (teams.isEmpty) return const _EmptyTeams();
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
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

class _EmptyTeams extends StatelessWidget {
  const _EmptyTeams();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No teams yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first team to start building the tournament.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
