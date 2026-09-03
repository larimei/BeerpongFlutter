import 'package:flutter/material.dart';

import '../../domain/competition.dart';

Widget tournamentModeField({
  Key? key,
  required TournamentMode value,
  required ValueChanged<TournamentMode> onChanged,
}) => DropdownButtonFormField<TournamentMode>(
  key: key,
  initialValue: value,
  isExpanded: true,
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white,
    labelText: 'Tournament mode',
  ),
  items: TournamentMode.values
      .map((mode) => DropdownMenuItem(value: mode, child: Text(mode.label)))
      .toList(),
  onChanged: (mode) {
    if (mode != null) onChanged(mode);
  },
);
