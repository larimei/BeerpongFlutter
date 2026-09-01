import 'package:flutter/material.dart';

import '../../../teams/domain/team.dart';
import '../../domain/competition.dart';
import 'tournament_match_card.dart';

class RoundRobinTournamentTab extends StatefulWidget {
  const RoundRobinTournamentTab({
    required this.competition,
    required this.teams,
    required this.onConfirmWinner,
    super.key,
  });

  final Competition competition;
  final List<Team> teams;
  final bool Function(String matchId, String winnerTeamId) onConfirmWinner;

  @override
  State<RoundRobinTournamentTab> createState() =>
      _RoundRobinTournamentTabState();
}

class _RoundRobinTournamentTabState extends State<RoundRobinTournamentTab> {
  final Map<String, String> _selectedWinners = {};

  @override
  Widget build(BuildContext context) {
    final tournament = widget.competition.roundRobinTournament;
    final gradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [widget.competition.color, Colors.white],
      ),
    );
    if (tournament == null) {
      return Container(
        decoration: gradient,
        child: const Center(child: Text('No tournament generated yet.')),
      );
    }
    final names = {for (final team in widget.teams) team.id: team.name};
    final colors = {for (final team in widget.teams) team.id: team.color};
    return Container(
      key: const Key('round-robin-tournament-background'),
      decoration: gradient,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (tournament.isComplete)
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Winner: ${names[tournament.winnerTeamId] ?? tournament.winnerTeamId}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          Text('Games', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final match in tournament.matches) ...[
            TournamentMatchCard(
              teamIds: match.teamIds,
              names: names,
              colors: colors,
              winnerTeamId: match.winnerTeamId,
              selectedWinnerId: _selectedWinners[match.id],
              onWinnerSelected: (winnerId) =>
                  setState(() => _selectedWinners[match.id] = winnerId),
              onConfirm: () {
                final winner = _selectedWinners[match.id];
                if (winner != null &&
                    widget.onConfirmWinner(match.id, winner)) {
                  setState(() => _selectedWinners.remove(match.id));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Text('Standings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < tournament.standings.length;
                  index++
                )
                  ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(
                      names[tournament.standings[index].teamId] ??
                          tournament.standings[index].teamId,
                    ),
                    trailing: Text('${tournament.standings[index].wins} wins'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
