import 'package:flutter/material.dart';

import '../../features/players/domain/player.dart';
import '../../features/teams/presentation/widgets/add_team_form.dart';
import 'entity_add_form.dart';
import 'competition_placeholder_form.dart';

enum GlobalAddTarget { player, team, competition }

class GlobalAddOverlay extends StatelessWidget {
  const GlobalAddOverlay({
    required this.target,
    this.players = const [],
    super.key,
  });

  final GlobalAddTarget target;
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return switch (target) {
      GlobalAddTarget.player => EntityAddForm(
        entityName: 'player',
        icon: Icons.sports_bar_outlined,
        backgroundKey: const Key('add-player-background'),
        avatarKey: const Key('add-player-avatar'),
        iconKey: const Key('add-player-icon'),
        colorPickerIconKey: const Key('color-picker-player-icon'),
        colorPickerWheelKey: const Key('player-color-wheel'),
        onSubmit: (player) => Navigator.pop(context, player),
        onCancel: () => Navigator.pop(context),
      ),
      GlobalAddTarget.team => AddTeamForm(
        players: players,
        onSubmit: (team) => Navigator.pop(context, team),
        onCancel: () => Navigator.pop(context),
      ),
      GlobalAddTarget.competition => CompetitionPlaceholderForm(
        onBack: () => Navigator.pop(context),
      ),
    };
  }
}
