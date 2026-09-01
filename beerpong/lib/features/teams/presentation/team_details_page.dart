import 'package:flutter/material.dart';

import '../../../app/widgets/entity_details_content.dart';
import '../../../app/widgets/entity_edit_dialog.dart';
import '../../players/application/players_controller.dart';
import '../../players/domain/player.dart';
import '../application/teams_controller.dart';
import '../domain/team.dart';
import 'widgets/player_selection.dart';

class TeamDetailsPage extends StatelessWidget {
  const TeamDetailsPage({
    required this.teamId,
    required this.controller,
    required this.playersController,
    super.key,
  });

  final String teamId;
  final TeamsController controller;
  final PlayersController playersController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, playersController]),
      builder: (context, child) {
        final team = controller.teamById(teamId);
        final players = team == null ? <Player>[] : _playersFor(team.playerIds);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: team?.color ?? const Color(0xFFF0FAF9),
            title: const Text('Team details'),
          ),
          body: team == null
              ? const Center(child: Text('Team no longer exists'))
              : Container(
                  key: const Key('team-details-background'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [team.color, Colors.white],
                    ),
                  ),
                  child: EntityDetailsContent(
                    name: team.name,
                    color: team.color,
                    icon: Icons.groups_outlined,
                    won: team.won,
                    lost: team.lost,
                    entityName: 'team',
                    surfaceKey: const Key('team-details-surface'),
                    avatarKey: const Key('team-avatar'),
                    iconKey: const Key('team-details-icon'),
                    additionalContent: _TeamMembers(
                      players: players,
                      onManage: () => _managePlayers(context, team),
                    ),
                    onEdit: () => _editTeam(context, team),
                    onDelete: () => _deleteTeam(context, team),
                  ),
                ),
        );
      },
    );
  }

  List<Player> _playersFor(List<String> ids) => playersController.players
      .where((player) => ids.contains(player.id))
      .toList();

  Future<void> _editTeam(BuildContext context, Team team) async {
    final edits = await showDialog<EntityEdits>(
      context: context,
      builder: (context) => EntityEditDialog(
        entityName: 'team',
        initialName: team.name,
        initialColor: team.color,
        icon: Icons.groups_outlined,
        colorPickerIconKey: const Key('color-picker-team-icon'),
        colorPickerWheelKey: const Key('team-color-wheel'),
      ),
    );
    if (edits == null) return;
    controller.updateTeam(
      id: team.id,
      name: edits.name,
      playerIds: team.playerIds,
      color: edits.color,
    );
  }

  Future<void> _managePlayers(BuildContext context, Team team) async {
    final playerIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => _ManagePlayersDialog(
        players: playersController.players,
        initialPlayerIds: team.playerIds,
      ),
    );
    if (playerIds == null) return;
    controller.updateTeam(
      id: team.id,
      name: team.name,
      playerIds: playerIds,
      color: team.color,
    );
  }

  Future<void> _deleteTeam(BuildContext context, Team team) async {
    final competitionCount = controller.competitionCountForTeam(team.id);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete team?'),
        content: Text(
          competitionCount == 0
              ? 'Are you sure you want to delete ${team.name}?'
              : '${team.name} is assigned to $competitionCount '
                    '${competitionCount == 1 ? 'competition' : 'competitions'}. '
                    'Deleting it will remove it from '
                    '${competitionCount == 1 ? 'that competition' : 'those competitions'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!(shouldDelete ?? false) || !context.mounted) return;
    controller.deleteTeam(team.id);
    Navigator.pop(context);
  }
}

class _TeamMembers extends StatelessWidget {
  const _TeamMembers({required this.players, required this.onManage});

  final List<Player> players;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Players', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (players.isEmpty)
          const Text('No players in this team')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: players
                .map(
                  (player) => Chip(
                    avatar: CircleAvatar(backgroundColor: player.color),
                    label: Text(player.name),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onManage,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Manage players'),
        ),
      ],
    );
  }
}

class _ManagePlayersDialog extends StatefulWidget {
  const _ManagePlayersDialog({
    required this.players,
    required this.initialPlayerIds,
  });

  final List<Player> players;
  final List<String> initialPlayerIds;

  @override
  State<_ManagePlayersDialog> createState() => _ManagePlayersDialogState();
}

class _ManagePlayersDialogState extends State<_ManagePlayersDialog> {
  late final Set<String> _selectedPlayerIds;

  @override
  void initState() {
    super.initState();
    _selectedPlayerIds = widget.initialPlayerIds.toSet();
  }

  void _togglePlayer(String id) {
    setState(() {
      if (!_selectedPlayerIds.remove(id)) _selectedPlayerIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage players'),
      content: SizedBox(
        width: 420,
        child: PlayerSelection(
          players: widget.players,
          selectedPlayerIds: _selectedPlayerIds,
          onChanged: _togglePlayer,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedPlayerIds.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
