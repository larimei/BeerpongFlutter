import 'package:flutter/material.dart';

import '../../../app/widgets/entity_details_content.dart';
import '../../../app/widgets/collapsible_chip_list.dart';
import '../../../app/widgets/entity_edit_dialog.dart';
import '../../../app/widgets/entity_selection.dart';
import '../../teams/domain/team.dart';
import '../application/competitions_controller.dart';
import '../domain/competition.dart';
import 'widgets/knockout_tournament_tab.dart';
import 'widgets/round_robin_tournament_tab.dart';
import 'widgets/tournament_mode_field.dart';

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
        if (competition == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Competition details')),
            body: const Center(child: Text('Competition no longer exists')),
          );
        }
        final assignedTeams = teams
            .where((team) => competition.teamIds.contains(team.id))
            .toList();
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: competition.color,
              title: const Text('Competition details'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Tournament'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
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
                    topPadding: 0,
                    cardTopMargin: 18,
                    additionalContent: _CompetitionInformation(
                      competition: competition,
                      assignedTeams: assignedTeams,
                      onManageTeams: () => _manageTeams(context, competition),
                      onGenerateTournament: () =>
                          competition.mode == TournamentMode.knockout
                          ? controller.generateKnockoutTournament(
                              competition.id,
                            )
                          : controller.generateRoundRobinTournament(
                              competition.id,
                            ),
                      onResetTournament: () =>
                          _resetTournament(context, competition),
                    ),
                    onEdit: () => _editCompetition(context, competition),
                    onDelete: () => _deleteCompetition(context, competition),
                  ),
                ),
                competition.mode == TournamentMode.knockout
                    ? KnockoutTournamentTab(
                        competition: competition,
                        teams: assignedTeams,
                        onConfirmWinner: (matchId, winnerTeamId) =>
                            controller.confirmKnockoutMatchWinner(
                              competitionId: competition.id,
                              matchId: matchId,
                              winnerTeamId: winnerTeamId,
                              playerIdsByTeam: _playerIdsByTeam(assignedTeams),
                            ),
                        onClearOutcomePath: (matchId) =>
                            controller.clearKnockoutOutcomePath(
                              competitionId: competition.id,
                              matchId: matchId,
                            ),
                      )
                    : RoundRobinTournamentTab(
                        competition: competition,
                        teams: assignedTeams,
                        onConfirmWinner: (matchId, winnerTeamId) =>
                            controller.confirmRoundRobinMatchWinner(
                              competitionId: competition.id,
                              matchId: matchId,
                              winnerTeamId: winnerTeamId,
                              playerIdsByTeam: _playerIdsByTeam(assignedTeams),
                            ),
                        onClearResult: (matchId) =>
                            controller.clearRoundRobinMatchOutcome(
                              competitionId: competition.id,
                              matchId: matchId,
                            ),
                      ),
              ],
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
    if (!context.mounted) return;
    if (!_sameIds(competition.teamIds, savedTeamIds) &&
        !await _canReplacePlan(context, competition, teamIds: savedTeamIds)) {
      return;
    }
    if (!context.mounted) return;
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
          additionalFields: tournamentModeField(
            key: const Key('edit-competition-mode'),
            value: selectedMode,
            onChanged: (mode) => setDialogState(() => selectedMode = mode),
          ),
        ),
      ),
    );
    if (edits == null) return;
    if (!context.mounted) return;
    if (selectedMode != competition.mode &&
        !await _canReplacePlan(context, competition, mode: selectedMode)) {
      return;
    }
    if (!context.mounted) return;
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

  Future<void> _resetTournament(
    BuildContext context,
    Competition competition,
  ) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset tournament?'),
        content: const Text(
          'This removes the generated tournament and all confirmed outcomes. '
          'Derived team and player statistics will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset tournament'),
          ),
        ],
      ),
    );
    if (shouldReset ?? false) controller.resetTournament(competition.id);
  }

  Future<bool> _canReplacePlan(
    BuildContext context,
    Competition competition, {
    TournamentMode? mode,
    List<String>? teamIds,
  }) async {
    final hasTournament =
        competition.tournament != null ||
        competition.roundRobinTournament != null;
    if (!hasTournament) return true;
    if (!controller.canReplaceTournamentPlan(
      competitionId: competition.id,
      mode: mode,
      teamIds: teamIds,
    )) {
      await _resetTournament(context, competition);
      return controller.competitionById(competition.id)?.tournament == null &&
          controller.competitionById(competition.id)?.roundRobinTournament ==
              null;
    }
    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace tournament plan?'),
        content: const Text(
          'No game has been confirmed. This change will replace the generated '
          'tournament plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace plan'),
          ),
        ],
      ),
    );
    return shouldReplace ?? false;
  }
}

bool _sameIds(List<String> first, List<String> second) =>
    first.length == second.length && first.every(second.contains);

Map<String, List<String>> _playerIdsByTeam(List<Team> teams) => {
  for (final team in teams) team.id: team.playerIds,
};

class _CompetitionInformation extends StatelessWidget {
  const _CompetitionInformation({
    required this.competition,
    required this.assignedTeams,
    required this.onManageTeams,
    required this.onGenerateTournament,
    required this.onResetTournament,
  });

  final Competition competition;
  final List<Team> assignedTeams;
  final VoidCallback onManageTeams;
  final VoidCallback onGenerateTournament;
  final VoidCallback onResetTournament;

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
        Text('Teams', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (assignedTeams.isEmpty)
          const Text('No teams assigned')
        else
          CollapsibleChipList(
            children: assignedTeams
                .map(
                  (team) => Chip(
                    avatar: CircleAvatar(backgroundColor: team.color),
                    label: Text(team.name),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onManageTeams,
          icon: const Icon(Icons.groups_outlined),
          label: const Text('Manage teams'),
        ),
        if (competition.mode == TournamentMode.knockout ||
            competition.mode == TournamentMode.roundRobin) ...[
          const SizedBox(height: 12),
          if ((competition.mode == TournamentMode.knockout &&
                  competition.tournament == null) ||
              (competition.mode == TournamentMode.roundRobin &&
                  competition.roundRobinTournament == null))
            FilledButton.icon(
              onPressed: assignedTeams.length >= 2
                  ? onGenerateTournament
                  : null,
              icon: Icon(
                competition.mode == TournamentMode.knockout
                    ? Icons.account_tree_outlined
                    : Icons.leaderboard_outlined,
              ),
              label: const Text('Generate tournament'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  competition.mode == TournamentMode.knockout
                      ? 'Tournament bracket generated'
                      : 'Round-robin games generated',
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onResetTournament,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset tournament'),
                ),
              ],
            ),
          if (assignedTeams.length < 2 &&
              competition.tournament == null &&
              competition.roundRobinTournament == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Assign at least two teams to generate a tournament.',
              ),
            ),
        ],
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
