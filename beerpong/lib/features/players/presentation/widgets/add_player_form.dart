import 'package:flutter/material.dart';

import '../../../../app/data/entity_name_generator.dart';
import '../../../../app/widgets/entity_add_form.dart';

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
  late final Future<String> _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = EntityNameGenerator().randomName(EntityNameType.player);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialName,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        return EntityAddForm(
          entityName: 'player',
          icon: Icons.sports_bar_outlined,
          initialName: snapshot.data ?? '',
          backgroundKey: const Key('add-player-background'),
          avatarKey: const Key('add-player-avatar'),
          iconKey: const Key('add-player-icon'),
          colorPickerIconKey: const Key('color-picker-player-icon'),
          colorPickerWheelKey: const Key('player-color-wheel'),
          onSubmit: widget.onSubmit,
          onCancel: widget.onCancel,
        );
      },
    );
  }
}
