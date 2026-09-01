import 'package:flutter/material.dart';

import '../../../../app/data/entity_name_generator.dart';
import '../../../../app/widgets/entity_add_form.dart';
import '../../../../app/widgets/entity_selection.dart';
import '../../../players/domain/player.dart';

class NewTeam {
  const NewTeam({
    required this.name,
    required this.playerIds,
    required this.color,
  });

  final String name;
  final List<String> playerIds;
  final Color color;
}

class AddTeamForm extends StatefulWidget {
  const AddTeamForm({
    required this.players,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final List<Player> players;
  final ValueChanged<NewTeam> onSubmit;
  final VoidCallback onCancel;

  @override
  State<AddTeamForm> createState() => _AddTeamFormState();
}

class _AddTeamFormState extends State<AddTeamForm> {
  Set<String> _selectedPlayerIds = {};
  late final Future<String> _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = EntityNameGenerator().randomName(EntityNameType.team);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialName,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildForm(snapshot.data ?? '');
      },
    );
  }

  Widget _buildForm(String initialName) {
    return EntityAddForm(
      entityName: 'team',
      icon: Icons.groups_outlined,
      initialName: initialName,
      backgroundKey: const Key('add-team-background'),
      avatarKey: const Key('add-team-avatar'),
      iconKey: const Key('add-team-icon'),
      colorPickerIconKey: const Key('color-picker-team-icon'),
      colorPickerWheelKey: const Key('team-color-wheel'),
      additionalFields: EntitySelectionField<Player>(
        manageLabel: 'Manage players',
        icon: Icons.group_add_outlined,
        dialogTitle: 'Manage players',
        selectionLabel: 'Players',
        items: widget.players,
        selectedIds: _selectedPlayerIds,
        idOf: (player) => player.id,
        nameOf: (player) => player.name,
        emptyMessage: 'No players available. Add players first.',
        onChanged: (playerIds) =>
            setState(() => _selectedPlayerIds = playerIds),
      ),
      onSubmit: (team) => widget.onSubmit(
        NewTeam(
          name: team.name,
          playerIds: _selectedPlayerIds.toList(),
          color: team.color,
        ),
      ),
      onCancel: widget.onCancel,
    );
  }
}
