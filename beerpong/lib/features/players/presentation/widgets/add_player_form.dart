import 'package:flutter/material.dart';

import '../../../../app/widgets/entity_add_form.dart';
import '../../../../app/widgets/generated_entity_name.dart';
import '../../../../app/data/entity_name_generator.dart';

class AddPlayerForm extends StatefulWidget {
  const AddPlayerForm({
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final ValueChanged<NewEntity> onSubmit;
  final VoidCallback onCancel;

  @override
  State<AddPlayerForm> createState() => _AddPlayerFormState();
}

class _AddPlayerFormState extends State<AddPlayerForm> {
  @override
  Widget build(BuildContext context) {
    return GeneratedEntityName(
      type: EntityNameType.player,
      builder: (context, initialName) => EntityAddForm(
        entityName: 'player',
        icon: Icons.sports_bar_outlined,
        initialName: initialName,
        backgroundKey: const Key('add-player-background'),
        avatarKey: const Key('add-player-avatar'),
        iconKey: const Key('add-player-icon'),
        colorPickerIconKey: const Key('color-picker-player-icon'),
        colorPickerWheelKey: const Key('player-color-wheel'),
        onSubmit: widget.onSubmit,
        onCancel: widget.onCancel,
      ),
    );
  }
}
