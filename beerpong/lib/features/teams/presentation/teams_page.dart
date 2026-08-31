import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../players/application/players_controller.dart';
import '../application/teams_controller.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({
    required this.controller,
    required this.playersController,
    super.key,
  });

  final TeamsController controller;
  final PlayersController playersController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF9),
        title: const Text('Teams'),
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
              return EntityCard(
                name: team.name,
                color: team.color,
                icon: Icons.groups_outlined,
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
