import 'package:flutter/material.dart';

import '../../domain/competition.dart';
import '../../../teams/domain/team.dart';

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
    if (tournament == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No tournament generated yet.'),
        ),
      );
    }
    final names = {for (final team in widget.teams) team.id: team.name};
    final rounds = <int, List<KnockoutMatch>>{};
    for (final match in tournament.matches) {
      rounds.putIfAbsent(match.round, () => []).add(match);
    }
    return ListView(
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
            KnockoutMatchCard(
              match: match,
              names: names,
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

class KnockoutMatchCard extends StatelessWidget {
  const KnockoutMatchCard({
    required this.match,
    required this.names,
    required this.selectedWinnerId,
    required this.onWinnerSelected,
    required this.onConfirm,
    super.key,
  });

  final KnockoutMatch match;
  final Map<String, String> names;
  final String? selectedWinnerId;
  final ValueChanged<String> onWinnerSelected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final teamNames = match.teamIds
        .map((id) => id == null ? 'To be decided' : names[id] ?? id)
        .toList();
    if (match.isBye) {
      return Card(
        child: ListTile(title: Text('${teamNames.first} receives a bye')),
      );
    }
    if (match.winnerTeamId != null) {
      return Card(
        child: ListTile(
          title: Text('${teamNames.first} vs ${teamNames.last}'),
          subtitle: Text(
            'Winner: ${names[match.winnerTeamId] ?? match.winnerTeamId}',
          ),
        ),
      );
    }
    if (!match.isPlayable) {
      return Card(
        child: ListTile(
          title: Text('${teamNames.first} vs ${teamNames.last}'),
          subtitle: const Text('Waiting for both teams'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<String>(
              groupValue: selectedWinnerId,
              onChanged: (value) => onWinnerSelected(value!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: match.teamIds.first!,
                    title: Text(teamNames.first),
                  ),
                  RadioListTile<String>(
                    value: match.teamIds.last!,
                    title: Text(teamNames.last),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: selectedWinnerId == null ? null : onConfirm,
                child: const Text('Confirm winner'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
