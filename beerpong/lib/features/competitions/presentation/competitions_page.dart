import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../teams/domain/team.dart';
import '../application/competitions_controller.dart';
import 'competition_details_page.dart';

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({
    required this.controller,
    this.teams = const [],
    super.key,
  });

  final CompetitionsController controller;
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF9),
        title: const Text('Competitions'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final competitions = controller.competitions;
          final existingTeamIds = teams.map((team) => team.id).toSet();
          if (competitions.isEmpty) return const _EmptyCompetitions();
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: competitions.length,
            itemBuilder: (context, index) {
              final competition = competitions[index];
              final teamCount = competition.teamIds
                  .toSet()
                  .intersection(existingTeamIds)
                  .length;
              return EntityCard(
                name: competition.name,
                color: competition.color,
                icon: Icons.emoji_events_outlined,
                additionalContent: EntityCardText(
                  text:
                      '${competition.mode.label} · $teamCount '
                      '${teamCount == 1 ? 'team' : 'teams'}',
                  fontSize: 12,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CompetitionDetailsPage(
                      competitionId: competition.id,
                      controller: controller,
                      teams: teams,
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

class _EmptyCompetitions extends StatelessWidget {
  const _EmptyCompetitions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No competitions yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first competition to start a tournament.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
