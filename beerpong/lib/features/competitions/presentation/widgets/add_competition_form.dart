import 'package:flutter/material.dart';

import '../../../../app/widgets/entity_add_form.dart';
import '../../../../app/widgets/entity_selection.dart';
import '../../../../app/widgets/generated_entity_name.dart';
import '../../../../app/data/entity_name_generator.dart';
import '../../../teams/domain/team.dart';
import '../../domain/competition.dart';
import 'tournament_mode_field.dart';

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
  Set<String> _selectedTeamIds = {};

  @override
  Widget build(BuildContext context) {
    return GeneratedEntityName(
      type: EntityNameType.competition,
      builder: (context, initialName) => _buildForm(initialName),
    );
  }

  Widget _buildForm(String initialName) {
    return EntityAddForm(
      entityName: 'competition',
      icon: Icons.emoji_events_outlined,
      initialName: initialName,
      backgroundKey: const Key('add-competition-background'),
      avatarKey: const Key('add-competition-avatar'),
      iconKey: const Key('add-competition-icon'),
      colorPickerIconKey: const Key('color-picker-competition-icon'),
      colorPickerWheelKey: const Key('competition-color-wheel'),
      additionalFields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tournamentModeField(
            key: const Key('competition-mode'),
            value: _selectedMode,
            onChanged: (mode) => setState(() => _selectedMode = mode),
          ),
          const SizedBox(height: 24),
          EntitySelectionField<Team>(
            manageLabel: 'Add or remove teams',
            icon: Icons.groups_outlined,
            dialogTitle: 'Add or remove teams',
            selectionLabel: 'Teams',
            items: widget.teams,
            selectedIds: _selectedTeamIds,
            idOf: (team) => team.id,
            nameOf: (team) => team.name,
            emptyMessage: 'No teams available. You can add teams later.',
            onChanged: (teamIds) => setState(() => _selectedTeamIds = teamIds),
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
