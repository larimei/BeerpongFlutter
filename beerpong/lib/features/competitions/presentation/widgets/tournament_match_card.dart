import 'package:flutter/material.dart';

class TournamentMatchCard extends StatelessWidget {
  const TournamentMatchCard({
    required this.teamIds,
    required this.names,
    required this.colors,
    required this.selectedWinnerId,
    required this.onWinnerSelected,
    required this.onConfirm,
    this.winnerTeamId,
    this.isPlayable = true,
    this.isBye = false,
    super.key,
  });

  final List<String?> teamIds;
  final Map<String, String> names;
  final Map<String, Color> colors;
  final String? selectedWinnerId;
  final ValueChanged<String> onWinnerSelected;
  final VoidCallback onConfirm;
  final String? winnerTeamId;
  final bool isPlayable;
  final bool isBye;

  @override
  Widget build(BuildContext context) {
    if (isBye) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: _TeamBox(
                  teamId: teamIds.first,
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
    if (winnerTeamId != null) {
      return _resultCard(context, winnerId: winnerTeamId);
    }
    if (!isPlayable) {
      return _resultCard(context, subtitle: 'Waiting for both teams');
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
                      teamId: teamIds.first,
                      names: names,
                      colors: colors,
                      selected: selectedWinnerId == teamIds.first,
                      radioValue: teamIds.first,
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
                      selected: selectedWinnerId == teamIds.last,
                      radioValue: teamIds.last,
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

  Widget _resultCard(
    BuildContext context, {
    String? winnerId,
    String? subtitle,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: _MatchTeams(
        teamIds: teamIds,
        names: names,
        colors: colors,
        winnerId: winnerId,
        subtitle: subtitle,
      ),
    ),
  );
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
          Expanded(child: _box(teamIds.first)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('vs'),
          ),
          Expanded(child: _box(teamIds.last)),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  );

  Widget _box(String? teamId) => _TeamBox(
    teamId: teamId,
    names: names,
    colors: colors,
    selected: winnerId == teamId,
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
