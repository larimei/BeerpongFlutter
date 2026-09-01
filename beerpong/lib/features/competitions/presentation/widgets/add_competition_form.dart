import 'package:flutter/material.dart';

import '../../../../app/widgets/entity_add_form.dart';
import '../../../../app/widgets/entity_selection.dart';
import '../../../teams/domain/team.dart';
import '../../domain/competition.dart';

class NewCompetition {
  const NewCompetition({
    required this.name,
    required this.mode,
    required this.color,
    required this.teamIds,
  });

  final String name;
  final TournamentMode mode;
  final Color color;
  final List<String> teamIds;
}

class AddCompetitionForm extends StatefulWidget {
  const AddCompetitionForm({
    required this.onSubmit,
    required this.onCancel,
    this.teams = const [],
    super.key,
  });

  final ValueChanged<NewCompetition> onSubmit;
  final VoidCallback onCancel;
  final List<Team> teams;

  @override
  State<AddCompetitionForm> createState() => _AddCompetitionFormState();
}

class _AddCompetitionFormState extends State<AddCompetitionForm> {
  TournamentMode _selectedMode = TournamentMode.knockout;
  final Set<String> _selectedTeamIds = {};

  void _toggleTeam(String teamId) {
    setState(() {
      if (!_selectedTeamIds.remove(teamId)) _selectedTeamIds.add(teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return EntityAddForm(
      entityName: 'competition',
      icon: Icons.emoji_events_outlined,
      backgroundKey: const Key('add-competition-background'),
      avatarKey: const Key('add-competition-avatar'),
      iconKey: const Key('add-competition-icon'),
      colorPickerIconKey: const Key('color-picker-competition-icon'),
      colorPickerWheelKey: const Key('competition-color-wheel'),
      additionalFields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<TournamentMode>(
            key: const Key('competition-mode'),
            initialValue: _selectedMode,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              labelText: 'Tournament mode',
            ),
            items: TournamentMode.values
                .map(
                  (mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode.label)),
                )
                .toList(),
            onChanged: (mode) {
              if (mode != null) setState(() => _selectedMode = mode);
            },
          ),
          const SizedBox(height: 24),
          EntitySelection<Team>(
            label: 'Teams',
            items: widget.teams,
            selectedIds: _selectedTeamIds,
            idOf: (team) => team.id,
            nameOf: (team) => team.name,
            emptyMessage: 'No teams available. You can add teams later.',
            onToggle: _toggleTeam,
          ),
        ],
      ),
      onSubmit: (competition) => widget.onSubmit(
        NewCompetition(
          name: competition.name,
          mode: _selectedMode,
          color: competition.color,
          teamIds: _selectedTeamIds.toList(),
        ),
      ),
      onCancel: widget.onCancel,
    );
  }
}
