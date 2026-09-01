import 'package:flutter/material.dart';

import '../../../app/widgets/entity_details_content.dart';
import '../../../app/widgets/entity_edit_dialog.dart';
import '../../../app/widgets/entity_selection.dart';
import '../../teams/domain/team.dart';
import '../application/competitions_controller.dart';
import '../domain/competition.dart';

class CompetitionDetailsPage extends StatelessWidget {
  const CompetitionDetailsPage({
    required this.competitionId,
    required this.controller,
    this.teams = const [],
    super.key,
  });

  final String competitionId;
  final CompetitionsController controller;
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final competition = controller.competitionById(competitionId);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: competition?.color ?? const Color(0xFFF0FAF9),
            title: const Text('Competition details'),
          ),
          body: competition == null
              ? const Center(child: Text('Competition no longer exists'))
              : Container(
                  key: const Key('competition-details-background'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [competition.color, Colors.white],
                    ),
                  ),
                  child: EntityDetailsContent(
                    name: competition.name,
                    color: competition.color,
                    icon: Icons.emoji_events_outlined,
                    won: 0,
                    lost: 0,
                    showStatistics: false,
                    entityName: 'competition',
                    surfaceKey: const Key('competition-details-surface'),
                    avatarKey: const Key('competition-avatar'),
                    iconKey: const Key('competition-details-icon'),
                    additionalContent: _CompetitionInformation(
                      competition: competition,
                      assignedTeams: teams
                          .where(
                            (team) => competition.teamIds.contains(team.id),
                          )
                          .toList(),
                      onManageTeams: () => _manageTeams(context, competition),
                    ),
                    onEdit: () => _editCompetition(context, competition),
                    onDelete: () => _deleteCompetition(context, competition),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _manageTeams(
    BuildContext context,
    Competition competition,
  ) async {
    final savedTeamIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => EntitySelectionDialog<Team>(
        title: 'Add or remove teams',
        label: 'Teams',
        items: teams,
        initialIds: competition.teamIds,
        idOf: (team) => team.id,
        nameOf: (team) => team.name,
        emptyMessage: 'No teams available. Add teams first.',
      ),
    );
    if (savedTeamIds == null) return;
    controller.updateCompetitionTeams(
      id: competition.id,
      teamIds: savedTeamIds,
    );
  }

  Future<void> _editCompetition(
    BuildContext context,
    Competition competition,
  ) async {
    var selectedMode = competition.mode;
    final edits = await showDialog<EntityEdits>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => EntityEditDialog(
          entityName: 'competition',
          initialName: competition.name,
          initialColor: competition.color,
          icon: Icons.emoji_events_outlined,
          colorPickerIconKey: const Key('color-picker-competition-icon'),
          colorPickerWheelKey: const Key('competition-color-wheel'),
          additionalFields: DropdownButtonFormField<TournamentMode>(
            key: const Key('edit-competition-mode'),
            initialValue: selectedMode,
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
              if (mode != null) {
                setDialogState(() => selectedMode = mode);
              }
            },
          ),
        ),
      ),
    );
    if (edits == null) return;
    controller.updateCompetition(
      id: competition.id,
      name: edits.name,
      mode: selectedMode,
      color: edits.color,
    );
  }

  Future<void> _deleteCompetition(
    BuildContext context,
    Competition competition,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete competition?'),
        content: Text('Are you sure you want to delete ${competition.name}?'),
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
    controller.deleteCompetition(competition.id);
    Navigator.pop(context);
  }
}

class _CompetitionInformation extends StatelessWidget {
  const _CompetitionInformation({
    required this.competition,
    required this.assignedTeams,
    required this.onManageTeams,
  });

  final Competition competition;
  final List<Team> assignedTeams;
  final VoidCallback onManageTeams;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InformationRow(
          label: 'Tournament mode',
          value: Text(competition.mode.label),
        ),
        const SizedBox(height: 16),
        _InformationRow(
          label: 'Teams',
          value: Text('${competition.teamIds.length}'),
        ),
        const SizedBox(height: 8),
        if (assignedTeams.isEmpty)
          const Text('No teams assigned')
        else
          ...assignedTeams.map(
            (team) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(radius: 12, backgroundColor: team.color),
              title: Text(team.name),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onManageTeams,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Add or remove teams'),
          ),
        ),
        const SizedBox(height: 16),
        _InformationRow(
          label: 'Competition color',
          value: Container(
            key: const Key('competition-color-preview'),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: competition.color,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        value,
      ],
    );
  }
}
