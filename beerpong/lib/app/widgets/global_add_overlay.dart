import 'package:flutter/material.dart';

import '../../features/competitions/presentation/widgets/add_competition_form.dart';
import '../../features/players/domain/player.dart';
import '../../features/players/presentation/widgets/add_player_form.dart';
import '../../features/teams/presentation/widgets/add_team_form.dart';
import '../../features/teams/domain/team.dart';

enum GlobalAddTarget { player, team, competition }

class GlobalAddOverlay extends StatelessWidget {
  const GlobalAddOverlay({
    required this.target,
    this.players = const [],
    this.teams = const [],
    super.key,
  });

  final GlobalAddTarget target;
  final List<Player> players;
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return switch (target) {
      GlobalAddTarget.player => AddPlayerForm(
        onSubmit: (player) => Navigator.pop(context, player),
        onCancel: () => Navigator.pop(context),
      ),
      GlobalAddTarget.team => AddTeamForm(
        players: players,
        onSubmit: (team) => Navigator.pop(context, team),
        onCancel: () => Navigator.pop(context),
      ),
      GlobalAddTarget.competition => AddCompetitionForm(
        teams: teams,
        onSubmit: (competition) => Navigator.pop(context, competition),
        onCancel: () => Navigator.pop(context),
      ),
    };
  }
}
