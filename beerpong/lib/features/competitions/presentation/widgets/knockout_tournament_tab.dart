import 'package:flutter/material.dart';

import '../../../teams/domain/team.dart';
import '../../domain/competition.dart';
import 'tournament_match_card.dart';

class KnockoutTournamentTab extends StatefulWidget {
  const KnockoutTournamentTab({
    required this.competition,
    required this.teams,
    required this.onConfirmWinner,
    super.key,
  });

  final Competition competition;
  final List<Team> teams;
  final bool Function(String matchId, String winnerTeamId) onConfirmWinner;

  @override
  State<KnockoutTournamentTab> createState() => _KnockoutTournamentTabState();
}

class _KnockoutTournamentTabState extends State<KnockoutTournamentTab> {
  final Map<String, String> _selectedWinners = {};

  @override
  Widget build(BuildContext context) {
    final tournament = widget.competition.tournament;
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No tournament generated yet.'),
          ),
        ),
      );
    }
    final names = {for (final team in widget.teams) team.id: team.name};
    final colors = {for (final team in widget.teams) team.id: team.color};
    final rounds = <int, List<KnockoutMatch>>{};
    for (final match in tournament.matches) {
      rounds.putIfAbsent(match.round, () => []).add(match);
    }
    return Container(
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
                  'Winner: ${_teamName(tournament.winnerTeamId, names)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          for (final entry in rounds.entries) ...[
            Text(
              _roundName(entry.key, rounds.length),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final match in entry.value) ...[
              TournamentMatchCard(
                teamIds: match.teamIds,
                names: names,
                colors: colors,
                winnerTeamId: match.winnerTeamId,
                isPlayable: match.isPlayable,
                isBye: match.isBye,
                selectedWinnerId: _selectedWinners[match.id],
                onWinnerSelected: (winner) =>
                    setState(() => _selectedWinners[match.id] = winner),
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
          ],
        ],
      ),
    );
  }

  String _teamName(String? teamId, Map<String, String> names) =>
      teamId == null ? 'To be decided' : names[teamId] ?? teamId;

  String _roundName(int round, int roundCount) {
    if (round == roundCount - 1) return 'Final';
    if (round == roundCount - 2) return 'Semi-finals';
    return 'Round ${round + 1}';
  }
}
