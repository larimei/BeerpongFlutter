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
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [widget.competition.color, Colors.white],
          ),
        ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.competition.color, Colors.white],
        ),
      ),
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
              KnockoutMatchCard(
                match: match,
                names: names,
                colors: colors,
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

class KnockoutMatchCard extends StatelessWidget {
  const KnockoutMatchCard({
    required this.match,
    required this.names,
    required this.colors,
    required this.selectedWinnerId,
    required this.onWinnerSelected,
    required this.onConfirm,
    super.key,
  });

  final KnockoutMatch match;
  final Map<String, String> names;
  final Map<String, Color> colors;
  final String? selectedWinnerId;
  final ValueChanged<String> onWinnerSelected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    if (match.isBye) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: _TeamBox(
                  teamId: match.teamIds.first,
                  names: names,
                  colors: colors,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('BYE'),
              ),
              const Expanded(child: _TeamBox(teamId: null, names: {})),
            ],
          ),
        ),
      );
    }
    if (match.winnerTeamId != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _MatchTeams(
            teamIds: match.teamIds,
            names: names,
            colors: colors,
            winnerId: match.winnerTeamId,
          ),
        ),
      );
    }
    if (!match.isPlayable) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _MatchTeams(
            teamIds: match.teamIds,
            names: names,
            colors: colors,
            subtitle: 'Waiting for both teams',
          ),
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
              child: Row(
                children: [
                  Expanded(
                    child: _TeamBox(
                      teamId: match.teamIds.first,
                      names: names,
                      colors: colors,
                      selected: selectedWinnerId == match.teamIds.first,
                      radioValue: match.teamIds.first,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('vs'),
                  ),
                  Expanded(
                    child: _TeamBox(
                      teamId: match.teamIds.last,
                      names: names,
                      colors: colors,
                      selected: selectedWinnerId == match.teamIds.last,
                      radioValue: match.teamIds.last,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: selectedWinnerId == null ? null : onConfirm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: const Text('Confirm winner'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchTeams extends StatelessWidget {
  const _MatchTeams({
    required this.teamIds,
    required this.names,
    required this.colors,
    this.winnerId,
    this.subtitle,
  });

  final List<String?> teamIds;
  final Map<String, String> names;
  final Map<String, Color> colors;
  final String? winnerId;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _TeamBox(
              teamId: teamIds.first,
              names: names,
              colors: colors,
              selected: winnerId == teamIds.first,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('vs'),
          ),
          Expanded(
            child: _TeamBox(
              teamId: teamIds.last,
              names: names,
              colors: colors,
              selected: winnerId == teamIds.last,
            ),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  );
}

class _TeamBox extends StatelessWidget {
  const _TeamBox({
    required this.teamId,
    required this.names,
    this.colors = const {},
    this.selected = false,
    this.radioValue,
  });

  final String? teamId;
  final Map<String, String> names;
  final Map<String, Color> colors;
  final bool selected;
  final String? radioValue;

  @override
  Widget build(BuildContext context) {
    final color = teamId == null ? Colors.grey : colors[teamId] ?? Colors.grey;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.7),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (radioValue != null) Radio<String>(value: radioValue!),
          Flexible(
            child: Text(
              teamId == null ? 'To be decided' : names[teamId] ?? teamId!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
