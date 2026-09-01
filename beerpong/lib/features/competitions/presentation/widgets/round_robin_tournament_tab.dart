import 'package:flutter/material.dart';

import '../../../teams/domain/team.dart';
import '../../domain/competition.dart';

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
  String? _selectedWinnerId;

  @override
  Widget build(BuildContext context) {
    final tournament = widget.competition.roundRobinTournament;
    if (tournament == null) {
      return const Center(child: Text('No tournament generated yet.'));
    }
    final names = {for (final team in widget.teams) team.id: team.name};
    final nextMatch = tournament.nextMatch;
    return ListView(
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
          )
        else ...[
          Text('Next game', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _MatchCard(
            match: nextMatch!,
            names: names,
            selectedWinnerId: _selectedWinnerId,
            onWinnerSelected: (winnerId) =>
                setState(() => _selectedWinnerId = winnerId),
            onConfirm: () {
              final winner = _selectedWinnerId;
              if (winner != null &&
                  widget.onConfirmWinner(nextMatch.id, winner)) {
                setState(() => _selectedWinnerId = null);
              }
            },
          ),
        ],
        const SizedBox(height: 24),
        Text('Standings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (var index = 0; index < tournament.standings.length; index++)
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
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.names,
    required this.selectedWinnerId,
    required this.onWinnerSelected,
    required this.onConfirm,
  });

  final RoundRobinMatch match;
  final Map<String, String> names;
  final String? selectedWinnerId;
  final ValueChanged<String> onWinnerSelected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioGroup<String>(
            groupValue: selectedWinnerId,
            onChanged: (winnerId) => onWinnerSelected(winnerId!),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: match.teamIds.first,
                  title: Text(
                    names[match.teamIds.first] ?? match.teamIds.first,
                  ),
                ),
                const Text('vs'),
                RadioListTile<String>(
                  value: match.teamIds.last,
                  title: Text(names[match.teamIds.last] ?? match.teamIds.last),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: selectedWinnerId == null ? null : onConfirm,
            child: const Text('Confirm winner'),
          ),
        ],
      ),
    ),
  );
}
