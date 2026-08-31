import 'package:flutter/material.dart';

import '../../../teams/domain/team.dart';

class TeamSelection extends StatelessWidget {
  const TeamSelection({
    required this.teams,
    required this.selectedTeamIds,
    required this.onChanged,
    super.key,
  });

  final List<Team> teams;
  final Set<String> selectedTeamIds;
  final ValueChanged<Set<String>> onChanged;

  void _toggleTeam(String teamId) {
    final updatedTeamIds = {...selectedTeamIds};
    if (!updatedTeamIds.remove(teamId)) updatedTeamIds.add(teamId);
    onChanged(updatedTeamIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Teams', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (teams.isEmpty)
          const Text('No teams available. You can add teams later.')
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                shrinkWrap: true,
                children: teams
                    .map(
                      (team) => CheckboxListTile(
                        value: selectedTeamIds.contains(team.id),
                        onChanged: (_) => _toggleTeam(team.id),
                        title: Text(team.name),
                        secondary: CircleAvatar(
                          radius: 12,
                          backgroundColor: team.color,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
