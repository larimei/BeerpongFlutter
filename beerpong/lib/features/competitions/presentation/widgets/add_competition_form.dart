import 'package:flutter/material.dart';

import '../../../../app/widgets/entity_add_form.dart';
import '../../domain/competition.dart';

class NewCompetition {
  const NewCompetition({
    required this.name,
    required this.mode,
    required this.color,
  });

  final String name;
  final TournamentMode mode;
  final Color color;
}

class AddCompetitionForm extends StatefulWidget {
  const AddCompetitionForm({
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final ValueChanged<NewCompetition> onSubmit;
  final VoidCallback onCancel;

  @override
  State<AddCompetitionForm> createState() => _AddCompetitionFormState();
}

class _AddCompetitionFormState extends State<AddCompetitionForm> {
  TournamentMode _selectedMode = TournamentMode.knockout;

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
      additionalFields: DropdownButtonFormField<TournamentMode>(
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
              (mode) => DropdownMenuItem(value: mode, child: Text(mode.label)),
            )
            .toList(),
        onChanged: (mode) {
          if (mode != null) setState(() => _selectedMode = mode);
        },
      ),
      onSubmit: (competition) => widget.onSubmit(
        NewCompetition(
          name: competition.name,
          mode: _selectedMode,
          color: competition.color,
        ),
      ),
      onCancel: widget.onCancel,
    );
  }
}
