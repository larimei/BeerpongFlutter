import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../../teams/domain/team.dart';
import '../application/competitions_controller.dart';
import '../domain/competition.dart';
import 'competition_details_page.dart';

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({
    required this.controller,
    this.teams = const [],
    this.onOpenSettings,
    super.key,
  });

  final CompetitionsController controller;
  final List<Team> teams;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF9),
        title: const Text('Competitions'),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
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
                additionalContent: _CompetitionCardDetails(
                  summary:
                      '${competition.mode.label} · $teamCount '
                      '${teamCount == 1 ? 'team' : 'teams'}',
                  status: _tournamentStatus(competition),
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

class _CompetitionCardDetails extends StatelessWidget {
  const _CompetitionCardDetails({required this.summary, required this.status});

  final String summary;
  final String status;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: EntityCardText(
          text: summary,
          fontSize: 12,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      const SizedBox(height: 2),
      Expanded(
        child: EntityCardText(
          text: status,
          fontSize: 12,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}

String _tournamentStatus(Competition competition) {
  final isComplete = competition.mode == TournamentMode.knockout
      ? competition.tournament?.isComplete == true
      : competition.roundRobinTournament?.isComplete == true;
  if (isComplete) return 'Completed';
  final hasTournament = competition.mode == TournamentMode.knockout
      ? competition.tournament != null
      : competition.roundRobinTournament != null;
  return hasTournament ? 'Ongoing' : 'Not started';
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
