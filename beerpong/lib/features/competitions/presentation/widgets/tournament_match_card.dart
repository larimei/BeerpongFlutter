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
    this.onCorrectResult,
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
  final VoidCallback? onCorrectResult;
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
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _TeamBox(
                  teamId: null,
                  names: {},
                  emptyLabel: 'Freilos',
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (winnerTeamId != null) {
      return _resultCard(
        context,
        winnerId: winnerTeamId,
        onCorrectResult: onCorrectResult,
      );
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
            Row(
              children: [
                Expanded(
                  child: _TeamBox(
                    teamId: teamIds.first,
                    names: names,
                    colors: colors,
                    alignment: Alignment.centerLeft,
                    selected: selectedWinnerId == teamIds.first,
                    onSelected: () => onWinnerSelected(teamIds.first!),
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
                    alignment: Alignment.centerRight,
                    selected: selectedWinnerId == teamIds.last,
                    onSelected: () => onWinnerSelected(teamIds.last!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _actionButton(
              context,
              label: 'Confirm winner',
              onPressed: selectedWinnerId == null ? null : onConfirm,
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
    VoidCallback? onCorrectResult,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _MatchTeams(
            teamIds: teamIds,
            names: names,
            colors: colors,
            winnerId: winnerId,
            subtitle: subtitle,
          ),
          if (onCorrectResult != null) ...[
            const SizedBox(height: 8),
            _actionButton(
              context,
              label: 'Correct result',
              onPressed: onCorrectResult,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      child: Text(label),
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
          Expanded(child: _box(teamIds.first, Alignment.centerLeft)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('vs'),
          ),
          Expanded(child: _box(teamIds.last, Alignment.centerRight)),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  );

  Widget _box(String? teamId, Alignment alignment) => _TeamBox(
    teamId: teamId,
    names: names,
    colors: colors,
    alignment: alignment,
    selected: winnerId == teamId,
  );
}

class _TeamBox extends StatelessWidget {
  const _TeamBox({
    required this.teamId,
    required this.names,
    this.colors = const {},
    this.selected = false,
    this.emptyLabel = 'To be decided',
    this.onSelected,
    this.alignment = Alignment.center,
  });

  final String? teamId;
  final Map<String, String> names;
  final Map<String, Color> colors;
  final bool selected;
  final String emptyLabel;
  final VoidCallback? onSelected;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = teamId == null ? Colors.grey : colors[teamId] ?? Colors.grey;
    final chip = Chip(
      avatar: CircleAvatar(backgroundColor: color),
      label: Text(
        teamId == null ? emptyLabel : names[teamId] ?? teamId!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
      ),
      side: BorderSide(
        color: selected ? color : Theme.of(context).colorScheme.outline,
        width: selected ? 2 : 1,
      ),
    );
    return Semantics(
      button: onSelected != null,
      selected: selected,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Align(alignment: alignment, child: chip),
      ),
    );
  }
}
